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
 * Copyright: 2017-2018 sel-project
 * License: MIT
 * Authors: Kripth
 * Source: $(HTTP github.com/sel-project/sel-format/sel/format/terminal.d, sel/format/terminal.d)
 */
module sel.terminal;

import std.string : indexOf;

import sel.format;

import terminal : Terminal, Color, Foreground;

private Terminal _terminal;

static this() {
	_terminal = new Terminal();
}

void write(Terminal terminal, string message) {
	synchronized writeImpl(terminal, message);
}

void write(string message) {
	write(_terminal, message);
}

void writeln(Terminal terminal, string message) {
	write(terminal, message);
	terminal.reset();
	terminal.write("\n");
}

void writeln(string message) {
	writeln(_terminal, message);
}

void writeImpl(Terminal terminal, string message) {
	immutable i = message.indexOf('§');
	if(i != -1 && i < message.length - 2) {
		immutable c = message[i+2];
		if(c >= '0' && c <= '9' || c >= 'a' && c <= 'z' || c >= 'k' && c <= 'o' || c == 'r') {
			terminal.write(message[0..i]);
			applyFormat(terminal, c);
			writeImpl(terminal, message[i+3..$]);
		} else {
			terminal.write(message[0..i+1]);
			writeImpl(terminal, message[i+2..$]);
		}
	} else {
		terminal.write(message);
	}
}

enum char charOf(string code) = code[2];

private __gshared Foreground[char] __table;

shared static this() {
	
	import std.process : environment;
	
	if(environment.get("TERM").indexOf("256") != -1) {
		
		// should support 24-bit colours
		
		Foreground rgb(uint num) {
			return Foreground((num >> 16) & 0xFF, (num >> 8) & 0xFF, num & 0xFF);
		}
		
		with(Format) {
			
			__table[charOf!black] = rgb(0x000000);
			__table[charOf!darkBlue] = rgb(0x0000AA);
			__table[charOf!darkGreen] = rgb(0x00AA00);
			__table[charOf!darkAqua] = rgb(0x00AAAA);
			__table[charOf!darkRed] = rgb(0xAA0000);
			__table[charOf!darkPurple] = rgb(0xAA00AA);
			__table[charOf!gold] = rgb(0xFFAA00);
			__table[charOf!gray] = rgb(0xAAAAAA);
			__table[charOf!darkGray] = rgb(0x555555);
			__table[charOf!blue] = rgb(0x5555FF);
			__table[charOf!green] = rgb(0x55FF55);
			__table[charOf!aqua] = rgb(0x55FFFF);
			__table[charOf!red] = rgb(0xFF5555);
			__table[charOf!lightPurple] = rgb(0xFF55FF);
			__table[charOf!yellow] = rgb(0xFFFF55);
			__table[charOf!white] = rgb(0xFFFFFF);
			
		}
		
	} else {

		with(Format) {
		
			__table[charOf!black] = Color.black;
			__table[charOf!darkBlue] = Color.blue;
			__table[charOf!darkGreen] = Color.green;
			__table[charOf!darkAqua] = Color.cyan;
			__table[charOf!darkRed] = Color.red;
			__table[charOf!darkPurple] = Color.magenta;
			__table[charOf!gold] = Color.yellow;
			__table[charOf!gray] = Color.lightGray;
			__table[charOf!darkGray] = Color.gray;
			__table[charOf!blue] = Color.brightBlue;
			__table[charOf!green] = Color.brightGreen;
			__table[charOf!aqua] = Color.brightCyan;
			__table[charOf!red] = Color.brightRed;
			__table[charOf!lightPurple] = Color.brightMagenta;
			__table[charOf!yellow] = Color.brightYellow;
			__table[charOf!white] = Color.white;

		}
		
	}
	
}

private void applyFormat(Terminal terminal, char c) {
	switch(c) with(Format) {
		case charOf!obfuscated: break; // not supported
		case charOf!bold:
			terminal.bold = true;
			break;
		case charOf!strikethrough:
			terminal.strikethrough = true;
			break;
		case charOf!underlined:
			terminal.underlined = true;
			break;
		case charOf!italic:
			terminal.italic = true;
			break;
		case charOf!reset:
			terminal.reset();
			break;
		default:
			terminal.foreground = __table[c];
			break;
	}
}

unittest {

	foreach(immutable member ; __traits(allMembers, Format)) {
		with(Format) writeln(mixin(member) ~ member);
	}

	foreach(immutable member ; __traits(allMembers, Format)) {
		with(Format) write(mixin(member) ~ "#");
	}

	_terminal.writeln();

}
