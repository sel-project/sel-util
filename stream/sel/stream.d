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

import std.system : Endian;
import std.typetuple : TypeTuple;

import libasync;

import xbuffer.buffer : Buffer, BufferOverflowException;
import xbuffer.varint : isVar;

/**
 * Generic stream.
 */
class Stream {

	private AsyncTCPConnection conn;
	private Buffer buffer;

	public void delegate(Buffer) handler;

	public Modifier modifier;

	this(AsyncTCPConnection conn, void delegate(Buffer) handler) {
		this.conn = conn;
		this.buffer = new Buffer(1024);
		this.handler = handler;
		this.modifier = new BaseModifier(this);
	}

	this(AsyncTCPConnection conn) {
		this(conn, (Buffer buffer){});
	}

	this(EventLoop eventLoop, string ip, ushort port) {
		this(new AsyncTCPConnection(eventLoop));
		this.conn.host(ip, port);
		this.conn.run(&this.handle);
	}

	private void handle(TCPEvent event) {
		switch(event) with(TCPEvent) {
			case READ:
				this.buffer.reset();
				static ubyte[] buffer = new ubyte[4096];
				while(true) {
					auto len = this.conn.recv(buffer);
					if(len > 0) this.buffer.write(buffer[0..len]);
					if(len < buffer.length) break;
				}
				this.modifier.receive(this.buffer);
				break;
			case CLOSE:
				//TODO call close handler
				break;
			default:
				break;
		}
	}

	public void handleData() {
		this.modifier.receive(this.buffer);
	}

	public void send(Buffer buffer) {
		this.modifier.send(buffer);
	}

	public void sendData(Buffer buffer) {
		this.conn.send(buffer.data!ubyte);
	}

	public void modify(M:ComplexModifier, E...)(E args) {
		this.modifier = new M(this.modifier, args);
	}

	//TODO close method
	
}

class Modifier {

	abstract void send(Buffer buffer);

	abstract void receive(Buffer buffer);

}

class BaseModifier : Modifier {

	Stream stream;

	this(Stream stream) {
		this.stream = stream;
	}

	override void send(Buffer buffer) {
		this.stream.sendData(buffer);
	}

	override void receive(Buffer buffer) {
		this.stream.handler(buffer);
	}

}

class ComplexModifier : Modifier {

	protected Modifier base;

	protected this(Modifier base) {
		this.base = base;
	}

}

class LengthPrefixedModifier(T, Endian endianness=Endian.bigEndian) : ComplexModifier {

	static if(!isVar!T) alias E = TypeTuple!(T, endianness);
	else alias E = T;

	private size_t length = 0;

	this(Modifier base) {
		super(base);
	}

	override void send(Buffer buffer) {
		buffer.write!E(buffer.data.length, 0);
		this.base.send(buffer);
	}

	override void receive(Buffer buffer) {
		if(this.length == 0) {
			this.parseLength(buffer);
		} else {
			this.parseImpl(buffer);
		}
	}

	private void parseLength(Buffer buffer) {
		try {
			this.length = buffer.read!E();
			if(this.length != 0) this.parseImpl(buffer);
		} catch(BufferOverflowException) {}
	}

	private void parseImpl(Buffer buffer) {
		if(buffer.canRead(this.length)) {
			this.base.receive(new Buffer(buffer.read!(ubyte[])(this.length))); //TODO do not use the GC
			this.length = 0;
			this.parseLength(buffer);
		}
	}

}

class CompressedModifier(T, Endian endianness=Endian.bigEndian) : ComplexModifier {
	
	static if(!isVar!T) alias E = TypeTuple!(T, endianness);
	else alias E = T;

	private size_t thresold;

	this(Modifier base, size_t thresold) {
		super(base);
		this.thresold = thresold;
	}

	override void send(Buffer buffer) {
		if(buffer.data.length >= this.thresold) {
			//TODO compress
		} else {
			buffer.write!T(0, 0);
		}
		this.base.send(buffer);
	}

	override void receive(Buffer buffer) {
		size_t length = buffer.read!E();
		if(length == 0) {
			this.base.receive(buffer);
		} else {
			//TODO uncompress
		}
	}

}
