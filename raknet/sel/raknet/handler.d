/*
 * Copyright (c) 2018 sel-project
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */
module sel.raknet.handler;

import std.algorithm : min;
import std.bitmanip : nativeToLittleEndian, littleEndianToNative;
import std.conv : to;
import std.math : ceil;
import std.socket : Address;
import std.system : Endian;

import kiss.net.UdpSocket : UdpSocket;

import sel.raknet.packet : Ack, Nack;

import xbuffer : Buffer;

import std.stdio;

class RaknetHandler {

	private UdpSocket socket;
	private Address address;
	public immutable ushort mtu;

	private Buffer buffer;
	
	public bool acceptSplit = true;
	private ubyte[][][ushort] splits;
	private size_t[ushort] splitsCount;
	
	private int send_count = -1;
	private ushort split_id = 0;
	
	private ubyte[][int] sent;
	
	public this(UdpSocket socket, Address address, ushort mtu) {
		this.socket = socket;
		this.address = address;
		this.mtu = mtu;
		this.buffer = new Buffer(mtu + 128);
	}
	
	public void send(ubyte[] _buffer) {
		if(_buffer.length > this.mtu) {
			immutable count = to!uint(ceil(_buffer.length.to!float / this.mtu));
			immutable sizes = to!uint(ceil(_buffer.length.to!float / count));
			foreach(order ; 0..count) {
				immutable c = ++this.send_count;
				ubyte[] current = _buffer[order*sizes..min((order+1)*sizes, $)];
				ubyte[3] _count = nativeToLittleEndian(c)[0..3];
				buffer.data = [ubyte(140)];
				buffer.write(_count);
				buffer.write(ubyte(64 | 16)); // info
				buffer.write!(Endian.bigEndian)(cast(ushort)(current.length * 8));
				buffer.write(_count); // message index
				buffer.write!(Endian.bigEndian)(count);
				buffer.write!(Endian.bigEndian)(this.split_id);
				buffer.write!(Endian.bigEndian)(order);
				buffer.write(current);
				this.socket.sendTo(buffer.data, this.address);
				this.sent[c] = buffer.data!ubyte;
			}
			this.split_id++;
		} else {
			immutable c = ++this.send_count;
			ubyte[3] count = nativeToLittleEndian(c)[0..3];
			buffer.data = [ubyte(132)];
			buffer.write(count);
			buffer.write(ubyte(64)); // info
			buffer.write!(Endian.bigEndian)(cast(ushort)(_buffer.length * 8));
			buffer.write(count); // message index
			buffer.write(_buffer);
			this.sent[c] = buffer.data!ubyte;
			this.socket.sendTo(buffer.data, this.address);
		}
	}
	
	public ubyte[] handle(in ubyte[] buffer) {
		if(buffer.length) {
			switch(buffer[0]) {
				case Ack.ID:
					Ack packet = new Ack();
					packet.decode(buffer);
					//writeln("Ack: ", packet.packets);
					foreach(ack ; packet.packets) {
						if(ack.unique) {
							this.sent.remove(ack.first);
						} else {
							foreach(id ; ack.first..ack.last) this.sent.remove(id);
						}
					}
					break;
				case Nack.ID:
					Nack packet = new Nack();
					packet.decode(buffer);
					//writeln("Nack: ", packet.packets);
					void send(uint id) {
						auto sent = id in this.sent;
						if(sent) this.socket.sendTo(*sent, this.address);
					}
					foreach(nack ; packet.packets) {
						if(nack.unique) {
							send(nack.first);
						} else {
							foreach(id ; nack.first..nack.last) send(id);
						}
					}
					break;
				case 128:..case 143:
					if(buffer.length > 7) {
						ubyte[4] _count = buffer[1..4] ~ ubyte(0);
						immutable count = littleEndianToNative!int(_count);
						// send ack
						// id, length (2), unique, from (3), to (3)
						this.socket.sendTo([ubyte(192), ubyte(0), ubyte(1), ubyte(true)] ~ buffer[1..4], this.address);
						// handle packet
						this.buffer.data = buffer[4..$];
						size_t index = 4;
						immutable info = this.buffer.read!ubyte();
						this.buffer.read!ushort(); // length / 8
						if((info & 0x7F) >= 64) {
							this.buffer.readData(3); // message index
							if((info & 0x7F) >= 96) {
								this.buffer.readData(3); // order index
								this.buffer.readData(1); // order channel
							}
						}
						if(info & 0x10) {
							if(this.buffer.canRead(10) && this.acceptSplit) {
								return this.handleSplit(this.buffer.read!(Endian.bigEndian, uint)(), this.buffer.read!(Endian.bigEndian, ushort)(), this.buffer.read!(Endian.bigEndian, uint)(), this.buffer.data!ubyte);
							}
						} else {
							return this.buffer.data!ubyte;
						}
					}
					break;
				default:
					break;
			}
		}
		return [];
	}
	
	private ubyte[] handleSplit(uint count, ushort id, uint order, ubyte[] buffer) {
		auto split = id in this.splits;
		if(split is null) {
			//TODO limit count
			this.splits[id].length = count;
			split = id in this.splits;
		}
		if(count == (*split).length && order < count) {
			(*split)[order] = buffer;
			if(++this.splitsCount[id] == count) {
				ubyte[] ret;
				foreach(b ; *split) {
					ret ~= b.dup;
				}
				this.splits.remove(id);
				this.splitsCount.remove(id);
				return ret;
			}
		}
		return [];
	}
	
	private static int readTriad(ubyte[] data) {
		ubyte[4] bytes = data ~ ubyte(0);
		return littleEndianToNative!int(bytes);
	}
	
	private static int[] getAck(ubyte[] buffer) {
		int[] ret;
		size_t index = 1;
		foreach(i ; 0..buffer[index++]) {
			if(buffer[index++]) {
				ret ~= readTriad(buffer[index..index+=3]);
			} else {
				foreach(num ; readTriad(buffer[index..index+=3])..readTriad(buffer[index..index+=3])+1) {
					ret ~= num;
				}
			}
		}
		return ret;
	}

}