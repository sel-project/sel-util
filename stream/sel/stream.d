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

import xbuffer.buffer : Buffer, BufferOverflowException;
import xbuffer.varint : isVar;

/**
 * Generic stream.
 */
class Stream {

	private void delegate(Buffer) _send, _recv;

	public this(void delegate(Buffer) send, void delegate(Buffer) recv) {
		_send = send;
		_recv = recv;
	}

	public void send(Buffer buffer) {
		_send(buffer);
	}

	public void parseInput(Buffer buffer) {
		_recv(buffer);
	}

	Stream encapsulate(T:Modifier, E...)(E args) {
		return new T(this, args);
	}
	
}

class Modifier : Stream {

	this(Stream stream) {
		super(stream._send, stream._recv);
	}

}

class LengthPrefixedStream(T, Endian endianness=Endian.bigEndian) : Modifier {

	static if(!isVar!T) alias E = TypeTuple!(T, endianness);
	else alias E = T;

	private size_t length = 0;

	this(Stream stream) {
		super(stream);
	}

	override void send(Buffer buffer) {
		buffer.write!E(buffer.data.length, 0);
		super.send(buffer);
	}

	override void parseInput(Buffer buffer) {
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
			super.parseInput(new Buffer(buffer.read!(ubyte[])(this.length))); //TODO do not use the GC
			this.length = 0;
			this.parseLength(buffer);
		}
	}

}

class CompressedStream(T, Endian endianness=Endian.bigEndian) : Modifier {
	
	static if(!isVar!T) alias E = TypeTuple!(T, endianness);
	else alias E = T;

	private size_t thresold;

	this(Stream stream, size_t thresold) {
		super(stream);
		this.thresold = thresold;
	}

	override void send(Buffer buffer) {
		if(buffer.data.length >= this.thresold) {
			//TODO compress
		} else {
			buffer.write!T(0, 0);
		}
		super.send(buffer);
	}

	override void parseInput(Buffer buffer) {
		size_t length = buffer.read!E();
		if(length == 0) {
			super.parseInput(buffer);
		} else {
			//TODO uncompress
		}
	}

}
