﻿/*
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
 * Source: $(HTTP github.com/sel-project/sel-util/protocols/sel/protocols.d, sel/protocols.d)
 */
module sel.protocols;

enum string[][uint] bedrockProtocols = [
	137: ["1.2.0", "1.2.1", "1.2.2", "1.2.3"],
	141: ["1.2.5"],
	150: ["1.2.6"],
	160: ["1.2.7", "1.2.8", "1.2.9"],
	201: ["1.2.10", "1.2.11"],
	261: ["1.4.0", "1.4.1", "1.4.2", "1.4.3", "1.4.4"],
	274: ["1.5.0", "1.5.1", "1.5.2", "1.5.3"],
	282: ["1.6.0"],
];

enum string[][uint] javaProtocols = [
	4: ["1.7.1-pre", "1.7.2", "1.7.3-pre", "1.7.4", "1.7.5"],
	5: ["1.7.6", "1.7.7", "1.7.8", "1.7.9", "1.7.10", "14w02a"],
	6: ["14w03a"],
	7: ["14w04a"],
	8: ["14w04b"],
	9: ["14w05a"],
	10: ["14w06a"],
	11: ["14w07a"],
	12: ["14w08a"],
	14: ["14w11a"],
	15: ["14w17a"],
	16: ["14w18b"],
	17: ["14w19a"],
	18: ["14w20a"],
	19: ["14w21a"],
	20: ["14w21b"],
	21: ["14w25a"],
	22: ["14w25b"],
	23: ["14w26a"],
	24: ["14w26b"],
	25: ["14w26c"],
	26: ["14w27a", "14w27b"],
	27: ["14w28a"],
	28: ["14w28b"],
	29: ["14w29a"],
	30: ["14w30a"],
	31: ["14w30c"],
	32: ["14w31a"],
	33: ["14w32a"],
	34: ["14w32b"],
	35: ["14w32c"],
	36: ["14w32d"],
	37: ["14w33a"],
	38: ["14w33b"],
	39: ["14w33c"],
	40: ["14w34a"],
	41: ["14w34b"],
	42: ["14w34c"],
	43: ["14w34d"],
	44: ["1.8-pre1"],
	45: ["1.8-pre2"],
	46: ["1.8-pre3"],
	47: ["1.8", "1.8.1", "1.8.2", "1.8.3", "1.8.4", "1.8.5", "1.8.6", "1.8.7", "1.8.8", "1.8.9"],
	48: ["15w14a"],
	49: ["15w31a"],
	50: ["15w31b"],
	51: ["15w31c"],
	52: ["15w32a"],
	53: ["15w32b"],
	54: ["15w32c"],
	55: ["15w33a"],
	56: ["15w33b"],
	57: ["15w33c"],
	58: ["15w34a"],
	59: ["15w34b"],
	60: ["15w34c"],
	61: ["15w34d"],
	62: ["15w35a"],
	63: ["15w35b"],
	64: ["15w35c"],
	65: ["15w35d"],
	66: ["15w35e"],
	67: ["15w36a"],
	68: ["15w36b"],
	69: ["15w36c"],
	70: ["15w36d"],
	71: ["15w37a"],
	72: ["15w38a"],
	73: ["15w38b"],
	74: ["15w39c"],
	75: ["15w40a"],
	76: ["15w40b"],
	77: ["15w41a"],
	78: ["15w41b"],
	79: ["15w42a"],
	80: ["15w43a"],
	81: ["15w43b"],
	82: ["15w43c"],
	83: ["15w44a"],
	84: ["15w44b"],
	85: ["15w45a"],
	86: ["15w46a"],
	87: ["15w47a"],
	88: ["15w47b"],
	89: ["15w47c"],
	90: ["15w49a"],
	91: ["15w49b"],
	92: ["15w50a"],
	93: ["15w51a"],
	94: ["15w51b"],
	95: ["16w02a"],
	96: ["16w03a"],
	97: ["16w04a"],
	98: ["16w05a"],
	99: ["16w05b"],
	100: ["16w06a"],
	101: ["16w07a"],
	102: ["16w07b"],
	103: ["1.9-pre1"],
	104: ["1.9-pre2"],
	105: ["1.9-pre3"],
	106: ["1.9-pre4"],
	107: ["1.9"],
	108: ["1.9.1-pre2"],
	109: ["1.9.2", "16w14a", "16w15a", "16w15b", "1.9.3-pre1", "1.9.3-pre3", "1.9.3", "1.9.4"],
	110: ["1.9.3-pre2"],
	201: ["16w20a"],
	202: ["16w21a"],
	203: ["16w21b"],
	204: ["1.10-pre1"],
	205: ["1.10-pre2"],
	210: ["1.10", "1.10.1", "1.10.2"],
	301: ["16w32a"],
	302: ["16w32b"],
	303: ["16w33a"],
	304: ["16w35a"],
	305: ["16w36a"],
	306: ["16w38a"],
	307: ["16w39a"],
	308: ["16w39b"],
	309: ["16w39c"],
	310: ["16w40a"],
	311: ["16w41a"],
	312: ["16w42a"],
	313: ["16w43a", "16w44a"],
	314: ["1.11-pre1"],
	315: ["1.11"],
	316: ["16w50a", "1.11.1", "1.11.2"],
	317: ["17w06a"],
	318: ["17w13a"],
	319: ["17w13b"],
	320: ["17w14a"],
	321: ["17w15a"],
	322: ["17w16a"],
	323: ["17w16b"],
	324: ["17w17a"],
	325: ["17w17b"],
	326: ["17w18a"],
	327: ["17w18b"],
	328: ["1.12-pre1"],
	329: ["1.12-pre2"],
	330: ["1.12-pre3"],
	331: ["1.12-pre4"],
	332: ["1.12-pre5"],
	333: ["1.12-pre6"],
	334: ["1.12-pre7"],
	335: ["1.12"],
	336: ["17w31a"],
	337: ["1.12.1-pre1"],
	338: ["1.12.1"],
	339: ["1.12.2-pre1", "1.12.2-pre2"],
	340: ["1.12.2"],
	341: ["17w43a"],
	342: ["17w43b"],
	343: ["17w45a"],
	344: ["17w45b"],
	345: ["17w46a"],
	346: ["17w47a"],
	347: ["17w47b"],
	348: ["17w48a"],
	349: ["17w49a"],
	350: ["17w49b"],
	351: ["17w50a"],
	352: ["18w01a"],
	353: ["18w02a"],
	354: ["18w03a"],
	355: ["18w03b"],
	356: ["18w05a"],
	357: ["18w06a"],
	358: ["18w07a"],
	359: ["18w07b"],
	360: ["18w07c"],
	361: ["18w08a"],
	362: ["18w08b"],
	363: ["18w09a"],
	364: ["18w10a"],
	365: ["18w10b"],
	366: ["18w10c"],
	367: ["18w10d"],
	368: ["18w11a"],
	369: ["18w14a"],
	370: ["18w14b"],
	371: ["18w15a"],
	372: ["18w16a"],
	373: ["18w19a"],
	374: ["18w19b"],
	375: ["18w20a"],
	376: ["18w20b"],
	377: ["18w20c"],
	378: ["18w21a"],
	379: ["18w21b"],
	380: ["18w22a"],
	381: ["18w22b"],
	382: ["18w22c"],
	383: ["1.13-pre1"],
	384: ["1.13-pre2"],
	385: ["1.13-pre3"],
	386: ["1.13-pre4"],
	387: ["1.13-pre5"],
	388: ["1.13-pre6"],
	389: ["1.13-pre7"],
	390: ["1.13-pre8"],
	391: ["1.13-pre9"],
	392: ["1.13-pre10"],
	393: ["1.13"],
	394: ["18w30a"],
	395: ["18w30b"],
	396: ["18w31a"],
	397: ["18w32a"],
	398: ["18w33a"],
	399: ["1.13.1-pre1"],
	400: ["1.13.1-pre2"],
	401: ["1.13.1"],
];
