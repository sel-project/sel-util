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
/**
 * Copyright: Copyright (c) 2018 sel-project
 * License: MIT
 * Authors: Kripth
 * Source: $(HTTP github.com/sel-project/sel-util/stream/sel/stream.d, sel/stream.d)
 */
module sel.stream;

import std.conv : to;
import std.socket : getAddress;
import std.system : Endian;
import std.typetuple : TypeTuple;
import std.zlib : Compress, UnCompress;

import kiss.event : EventLoop;
import kiss.net : TcpStream;

import xbuffer.buffer : Buffer, BufferOverflowException;
import xbuffer.varint : isVar;

/**
 * Generic stream.
 */
class Stream {

	TcpStream conn;
	Buffer buffer;

	public void delegate(Buffer) handler;

	public void delegate() onConnect, onClose;

	private Modifier[] modifiers;

	this(TcpStream conn, void delegate(Buffer) handler) {
		this.conn = conn;
		this.conn.onDataReceived = &this.handle;
		this.conn.onConnected((bool success){ onConnect(); });
		this.conn.onClosed({ onClose(); });
		this.buffer = new Buffer(1024);
		this.handler = handler;
		this.onConnect = {};
		this.onClose = {};
	}

	this(TcpStream conn) {
		this(conn, (Buffer buffer){});
	}

	this(EventLoop eventLoop, string ip, ushort port) {
		this(new TcpStream(eventLoop));
		this.conn.connect(getAddress(ip, port)[0]);
	}

	public void handle(in ubyte[] data) {
		this.buffer.data = data;
		this.handleData();
	}

	public void handleData() {
		bool more;
		do {
			more = false;
			foreach(modifier ; this.modifiers) {
				more |= modifier.decode(buffer);
			}
			if(buffer.data.length) this.handler(buffer);
		} while(more);
	}

	public void send(ubyte[] data) {
		this.buffer.data = data;
		this.send(this.buffer);
	}

	public void send(Buffer buffer) {
		foreach_reverse(modifier ; this.modifiers) {
			modifier.encode(buffer);
		}
		this.sendData(buffer);
		buffer.reset();
	}

	public void sendData(Buffer buffer) {
		this.conn.write(buffer.data!ubyte);
	}

	public void modify(M:Modifier, E...)(E args) {
		this.modifiers ~= new M(args);
	}
	
}

abstract class Modifier {

	abstract void encode(Buffer buffer);

	abstract bool decode(Buffer buffer);

}

class LengthPrefixedModifier(T, Endian endianness=Endian.bigEndian) : Modifier {

	static if(!isVar!T) alias E = TypeTuple!(T, endianness);
	else alias E = T;

	private size_t length = 0;
	private Buffer buffer;

	this() {
		this.buffer = new Buffer(1024);
	}

	override void encode(Buffer buffer) {
		static if(isVar!T) buffer.write!E(buffer.data.length.to!(T.Base), 0);
		else buffer.write!(endianness, T)(buffer.data.length.to!T, 0);
	}

	override bool decode(Buffer buffer) {
		buffer.data = this.buffer.data ~ buffer.data;
		if(this.length == 0) {
			return this.parseLength(buffer);
		} else {
			return this.parseImpl(buffer);
		}
	}

	private bool parseLength(Buffer buffer) {
		try {
			static if(isVar!T) this.length = buffer.read!E();
			else this.length = buffer.read!(endianness, T)();
			if(this.length != 0) return this.parseImpl(buffer);
			else return false;
		} catch(BufferOverflowException) {
			// cannot read the length
			this.buffer.data = buffer.data;
			return false;
		}
	}

	private bool parseImpl(Buffer buffer) {
		if(buffer.canRead(this.length)) {
			this.buffer.data = buffer.readData(this.length);
			this.length = 0;
			void[] rest = buffer.data;
			buffer.data = this.buffer.data;
			this.buffer.data = rest;
			return this.buffer.data.length > 0;
		} else {
			// not enough data to read
			this.buffer.data = buffer.data;
			return false;
		}
	}

}

class CompressedModifier(T, Endian endianness=Endian.bigEndian) : Modifier {
	
	static if(!isVar!T) alias E = TypeTuple!(T, endianness);
	else alias E = T;

	private size_t thresold;

	this(size_t thresold) {
		this.thresold = thresold;
	}

	override void encode(Buffer buffer) {
		if(buffer.data.length >= this.thresold) {
			immutable length = buffer.data.length;
			Compress c = new Compress();
			auto data = c.compress(buffer.data);
			data ~= c.flush();
			buffer.data = data;
			static if(isVar!T) buffer.write!E(length.to!(T.Base), 0);
			else buffer.write!E(length.to!T, 0);
		} else {
			buffer.write!T(0, 0);
		}
	}

	override bool decode(Buffer buffer) {
		try {
			size_t length = buffer.read!E();
			if(length != 0) {
				UnCompress uc = new UnCompress(length.to!uint);
				auto data = uc.uncompress(buffer.data);
				data ~= uc.flush();
				buffer.data = data;
			}
		} catch(BufferOverflowException) {}
		return false;
	}

}
