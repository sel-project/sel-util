/*
 * Copyright (c) 2018-2020 sel-project
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
 * Copyright: Copyright (c) 2018-2020 sel-project
 * License: MIT
 * Authors: Kripth
 * Source: $(HTTP github.com/sel-project/sel-util/raknet/sel/raknet/packet.d, sel/raknet/packet.d)
 */
module sel.raknet.packet;

import std.socket : SocketAddress = Address, InternetAddress, Internet6Address;
import std.system : Endian;

import xpacket;

alias RaknetPacket = PacketImpl!(Endian.bigEndian, ubyte, ushort);

// -----
// types
// -----

struct Magic {

	enum ubyte[16] constant = [0x00, 0xFF, 0xFF, 0x00, 0xFE, 0xFE, 0xFE, 0xFE, 0xFD, 0xFD, 0xFD, 0xFD, 0x12, 0x34, 0x56, 0x78];

	ubyte[16] value = constant;

	@property bool valid() pure nothrow @safe @nogc {
		return value == constant;
	}

}

struct Triad {

	union {

		int value;
		void[4] array;

	}

	void serialize(Buffer buffer) {
		version(LittleEndian) buffer.writeData(this.array[0..3]);
		else buffer.writeData(this.array[3], this.array[2], this.array[1]);
	}

	void deserialize(Buffer buffer) {
		version(LittleEndian) this.array[0..3] = buffer.readData(3);
		else {
			this.array[3] = buffer.read!ubyte();
			this.array[2] = buffer.read!ubyte();
			this.array[1] = buffer.read!ubyte();
		}
	}

	alias value this;

}

struct Address {

	ubyte type;
	@Condition("type==4") uint ipv4;
	@Condition("type==6") ubyte[16] ipv6;
	@Condition("type==6") ubyte[10] unknown;
	ushort port;

	this(SocketAddress address) {
		if(cast(InternetAddress)address) {
			InternetAddress addr = cast(InternetAddress)address;
			this.type = 4;
			this.ipv4 = addr.addr;
			this.port = addr.port;
		} else if(cast(Internet6Address)address) {
			Internet6Address addr = cast(Internet6Address)address;
			this.type = 6;
			this.ipv6 = addr.addr;
			this.port = addr.port;
		}
	}

}

struct Acknowledge {

	bool unique;
	Triad first;
	@Condition("!unique") Triad last;

}

struct Encapsulation {

	ubyte info;
	ushort length;
	@Condition("(info&0x7F) >= 64") Triad messageIndex;
	@Condition("(info&0x7F) >= 96") Triad orderIndex;
	@Condition("(info&0x7F) >= 96") Triad orderChannel;
	@Condition("(info&0x7F) != 0") Split split;
	@NoLength ubyte[] bytes;

}

struct Split {

	uint count;
	ushort id;
	uint order;

}

// -------
// control
// -------

class Ack : RaknetPacket {

	enum ubyte ID = 192;

	Acknowledge[] packets;

	mixin Make;

}

class Nack : RaknetPacket {

	enum ubyte ID = 160;

	Acknowledge[] packets;

	mixin Make;

}

class Encapsulated : RaknetPacket {

	Triad count;
	Encapsulation encapsulation;

	mixin Make;

}

// -----------
// unconnected
// -----------

class UnconnectedPing : RaknetPacket {

	enum ubyte ID = 1;

	long pingId;
	Magic magic;
	long guid;

	this() pure nothrow @safe @nogc {}

	this(long pingId, long guid) pure nothrow @safe @nogc {
		this.pingId = pingId;
		this.guid = guid;
	}

	mixin Make;

}

class UnconnectedPong : RaknetPacket {

	enum ubyte ID = 28;

	long pingId;
	long serverId;
	Magic magic;
	string status;

	this() pure nothrow @safe @nogc {}

	this(long pingId, long serverId, string status) pure nothrow @safe @nogc {
		this.pingId = pingId;
		this.serverId = serverId;
		this.status = status;
	}

	mixin Make;

}

class OpenConnectionRequest1 : RaknetPacket {

	enum ubyte ID = 5;

	Magic magic;
	ubyte protocol = 9;
	@NoLength ubyte[] mtu;

	this() pure nothrow @safe @nogc {}

	this(ubyte[] mtu) pure nothrow @safe @nogc {
		this.mtu = mtu;
	}

	mixin Make;

}

class OpenConnectionReply1 : RaknetPacket {

	enum ubyte ID = 6;

	Magic magic;
	long serverId;
	bool security;
	ushort mtuLength;

	this() pure nothrow @safe @nogc {}

	this(long serverId, bool security, ushort mtuLength) pure nothrow @safe @nogc {
		this.serverId = serverId;
		this.security = security;
		this.mtuLength = mtuLength;
	}
	
	mixin Make;

}

class OpenConnectionRequest2 : RaknetPacket {

	enum ubyte ID = 7;

	Magic magic;
	Address serverAddress;
	ushort mtuLength;
	long clientId;
	
	this() pure nothrow @safe @nogc {}

	this(Address serverAddress, ushort mtuLength, long clientId) pure nothrow @safe @nogc {
		this.serverAddress = serverAddress;
		this.mtuLength = mtuLength;
		this.clientId = clientId;
	}
	
	mixin Make;

}

class OpenConnectionReply2 : RaknetPacket {

	enum ubyte ID = 8;

	Magic magic;
	long serverId;
	Address clientAddress;
	ushort mtuLength;
	bool security;
	
	this() pure nothrow @safe @nogc {}

	this(long serverId, Address clientAddress, ushort mtuLength, bool security) pure nothrow @safe @nogc {
		this.serverId = serverId;
		this.clientAddress = clientAddress;
		this.mtuLength = mtuLength;
		this.security = security;
	}
	
	mixin Make;

}

// ------------
// encapsulated
// ------------

class ClientConnect : RaknetPacket {

	enum ubyte ID = 9;

	long clientId;
	long pingId;

	this() pure nothrow @safe @nogc {}

	this(long clientId, long pingId) pure nothrow @safe @nogc {
		this.clientId = clientId;
		this.pingId = pingId;
	}
	
	mixin Make;

}

class ServerHandshake : RaknetPacket {

	enum ubyte ID = 16;

	Address clientAddress;
	ushort mtuLength;
	Address[10] systemAddresses;
	long pingId;
	long serverId;

	this() pure nothrow @safe @nogc {}

	this(Address clientAddress, ushort mtuLength, Address[10] systemAddresses, long pingId, long serverId) pure nothrow @safe @nogc {
		this.clientAddress = clientAddress;
		this.mtuLength = mtuLength;
		this.systemAddresses = systemAddresses;
		this.pingId = pingId;
		this.serverId = serverId;
	}
	
	mixin Make;

}

class ClientHandshake : RaknetPacket {

	enum ubyte ID = 19;

	Address clientAddress;
	Address[10] systemAddresses;
	long pingId;
	long clientId;

	this() pure nothrow @safe @nogc {}

	this(Address clientAddress, Address[10] systemAddresses, long pingId, long clientId) pure nothrow @safe @nogc {
		this.clientAddress = clientAddress;
		this.systemAddresses = systemAddresses;
		this.pingId = pingId;
		this.clientId = clientId;
	}
	
	mixin Make;

}

class ClientCancelConnection : RaknetPacket {

	enum ubyte ID = 21;
	
	mixin Make;

}

class Ping : RaknetPacket {

	enum ubyte ID = 0;

	long time;

	this() pure nothrow @safe @nogc {}

	this(long time) pure nothrow @safe @nogc {
		this.time = time;
	}
	
	mixin Make;

}

class Pong : RaknetPacket {

	enum ubyte ID = 3;

	long time;
	
	this() pure nothrow @safe @nogc {}
	
	this(long time) pure nothrow @safe @nogc {
		this.time = time;
	}
	
	mixin Make;

}
