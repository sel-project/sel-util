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
 * Copyright: 2018 sel-project
 * License: MIT
 * Authors: Kripth
 * Source: $(HTTP github.com/sel-project/sel-format/sel/format/format.d, sel/format/format.d)
 */
module sel.format;

enum Format : string {
	
	black = "§0",
	darkBlue = "§1",
	darkGreen = "§2",
	darkAqua = "§3",
	darkRed = "§4",
	darkPurple = "§5",
	gold = "§6",
	gray = "§7",
	darkGray = "§8",
	blue = "§9",
	green = "§a",
	aqua = "§b",
	red = "§c",
	lightPurple = "§d",
	yellow = "§e",
	white = "§f",
	
	obfuscated = "§k",
	bold = "§l",
	strikethrough = "§m",
	underlined = "§n",
	italic = "§o",
	
	reset = "§r"
	
}

/**
 * Removes valid formatting codes from a string.
 */
pure nothrow @safe string unformat(string message) {
	for(ptrdiff_t i=0; message.length>2 && i<message.length-2; i++) {
		if(message[i] == 194 && message[i+1] == 167) {
			char next = message[i+2];
			if(next >= '0' && next <= '9' || next >= 'a' && next <= 'f' || next >= 'k' && next <= 'o' || next == 'r') {
				message = message[0..i] ~ message[i+3..$];
				if(--i > 0) i -= 2;
			}
		}
	}
	return message;
}

///
unittest {

	assert(unformat("§agreen") == "green");
	assert(unformat("res§ret") == "reset");
	assert(unformat("§xunsupported") == "§xunsupported");

	// consecutive
	assert(unformat("§§rr") == "");

}
