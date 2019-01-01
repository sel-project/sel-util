/*
 * Copyright (c) 2018-2019 sel-project
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
 * Copyright: Copyright (c) 2018-2019 sel-project
 * License: MIT
 * Authors: Kripth
 * Source: $(HTTP github.com/sel-project/sel-util/chat/sel/chat.d, sel/chat.d)
 */
module sel.chat;

import std.array : Appender;
import std.json;
import std.traits : EnumMembers;

import sel.format : Format;

public @safe string parseChat(JSONValue json) {
	Appender!string ret;
	parseChatImpl(ret, json);
	return ret.data;
}

private @trusted void parseChatImpl(ref Appender!string appender, JSONValue json) {
	if(json.type == JSON_TYPE.OBJECT) {
		auto translate = "translate" in json.object;
		if(translate && translate.type == JSON_TYPE.STRING) {
			// cannot translate without a translation table
			appender.put(translate.str);
		} else {
			auto color = "color" in json.object;
			string format;
			if(color && color.type == JSON_TYPE.STRING) {
				format = convertColor(color.str);
			}
			auto text = "text" in json.object;
			if(text && text.type == JSON_TYPE.STRING) {
				appender.put(format);
				appender.put(text.str);
			}
			auto extra = "extra" in json.object;
			if(extra && extra.type == JSON_TYPE.ARRAY) {
				foreach(i, element; extra.array) {
					parseChatImpl(appender, element);
					if(i < extra.array.length - 1) {
						appender.put(cast(string)Format.reset);
						appender.put(format);
					}
				}
			}
		}
	} else if(json.type == JSON_TYPE.STRING) {
		appender.put(json.str);
	}
}

private @safe string convertColor(string cname) {
	switch(cname) {
		foreach(format ; __traits(allMembers, Format)) {
			static if(isColor!format) {
				case snakeCase!format: return mixin("Format." ~ format);
			}
		}
		default: return "";
	}
}

@safe unittest {

	assert(convertColor("black") == Format.black);
	assert(convertColor("dark_blue") == Format.darkBlue);
	assert(convertColor("reset") == "");

}

private enum isColor(string format) = isColorImpl(mixin("Format." ~ format)[2]);

private bool isColorImpl(char c) {
	return c >= '0' && c <= '9' || c >= 'a' && c <= 'f';
}

private enum snakeCase(string str) = snakeCaseImpl(str);

private string snakeCaseImpl(string str) {
	string ret;
	foreach(c ; str) {
		if(c >= 'A' && c <= 'Z') ret ~= "_" ~ cast(char)(c + 32);
		else ret ~= c;
	}
	return ret;
}
