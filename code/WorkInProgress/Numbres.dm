/*MIT License

Copyright (c) 2023 anti software software club

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

// ported as a jape by warc because jae sais shi wouldn't
/datum/numbres //thats what im calling them sorry

/*
//this part, unfortunately, is not necessary for us because we already have helpers

lines (103 sloc) 4.05 KB
import { DateTime } from "luxon";
import React, {
	FunctionComponent,
	useCallback,
	useMemo,
	useState,
} from "react";

// seeded random number generator
// https://stackoverflow.com/a/47593316
function mulberry32(a: number) {
	return function () {
		let t = (a += 0x6d2b79f5);
		t = Math.imul(t ^ (t >>> 15), t | 1);
		t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
		return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
	};
}

function clamp(x: number, min: number, max: number) {
	return Math.min(Math.max(x, min), max);
}

function lerp(a: number, b: number, t: number) {
	return a + (b - a) * clamp(t, 0, 1);
}
*/
// Numbers will be live for 51 hours (midnight EDT on April 1 to 11:59pm PDT on April 2)
/datum/numbresTM/var/MAX_SECONDS = (48 + 3) * 60 * 60;
/datum/numbresTM/var/APRIL_1 = 0 // setting this in New() as that's non static when it's not, yknow, april 1st.

// coin flip odds of exponential growth
/datum/numbresTM/var/EXPONENT_THRESHOLD = 0.5;
/datum/numbresTM/var/MAX_EXPONENT = 1.42;

// 2% chance of fractional Numbers
/datum/numbresTM/var/FRACTION_THRESHOLD = 0.02;
/datum/numbresTM/var/MAX_DECIMAL_PLACES = 5;

/datum/numbresTM/New()
	..()
	APRIL_1 = world.time

// Since chaos day features go live at midnight EDT and Numbers is tied to
// midnight UTC, we will already have 4 hours (14400 seconds) on the clock,
// which gives us a starting maximum Number of 14,400. The feature shuts off at
// 7am UTC on april 3, so the max base Number will be around 200k
//None of the above is strictly true but im not about to go and delete a previous developer's comments, right?
/datum/numbresTM/proc/secondsFromDate(var/date)
	return abs(world.time - date);


/datum/numbresTM/proc/currentNegativeOdds()
	// we use real date and not effective date here since we want the negative
	// odds to be consistent through the weekend
	var/seconds = secondsFromDate(APRIL_1);
	var/odds = lerp(0.05, 0.6, seconds / MAX_SECONDS);
	return odds;

// here's where you left off, warc. ok go do errands and come back after.
/datum/numbresTM/proc/numbers(var/postId, var/publishedAt)
	// use the publish date if it's after april 1 so that numbers start small
	// for posts made while the feature is live.
	/*
	const effectiveDate = useMemo(() => {
		if (!publishedAt) {
			return APRIL_1;
		}

		const publishDateTime = DateTime.fromISO(publishedAt);
		return publishDateTime > APRIL_1 ? publishDateTime : APRIL_1;
	}, [publishedAt]);
	*/
	/*
	var/datum/xor_rand_generator/randFunc = new(postId)
	var/numberRoll = randFunc.xor_rand()
	var/negativeRoll = randFunc.xor_rand()
	var/fractionRoll = randFunc.xor_rand()
	var/exponentRoll = randFunc.xor_rand()
	*/
	/* Todo: The Rest. I just dont have the spoon.
	const [numberRoll, negativeRoll, fractionRoll, exponentRoll] = useMemo<
		[number, number, number, number]
	>(() => {
		return [randFunc(), randFunc(), randFunc(), randFunc()];
	}, [randFunc]);

	const [displaySeconds, setDisplaySeconds] = useState(
		secondsFromDate(effectiveDate)
	);

	const onClick = useCallback(() => {
		setDisplaySeconds(secondsFromDate(effectiveDate));
	}, [effectiveDate]);

	// get the actual Number to display
	const displayNumber = useMemo(() => {
		let displayNumber = numberRoll * displaySeconds;
		let decimalPlaces = 0;

		// fractional Numbers?
		if (fractionRoll <= FRACTION_THRESHOLD) {
			const normalizedFraction = fractionRoll / FRACTION_THRESHOLD;
			// add 1 to the max since we're flooring; makes the effective max
			// where we want it unless the roll is exactly 1.0 (rare!).
			decimalPlaces = Math.floor(
				lerp(1, MAX_DECIMAL_PLACES + 1, normalizedFraction)
			);
		}

		// exponential Numbers growth?
		if (exponentRoll <= EXPONENT_THRESHOLD) {
			const normalizedExponent = exponentRoll / EXPONENT_THRESHOLD;
			const exponent = lerp(1, MAX_EXPONENT, normalizedExponent);
			displayNumber = Math.pow(displayNumber, exponent);
		}

		if (negativeRoll <= currentNegativeOdds()) {
			displayNumber *= -1;
		}

		return displayNumber.toLocaleString(undefined, {
			maximumFractionDigits: decimalPlaces,
		});
	}, [displaySeconds, exponentRoll, fractionRoll, negativeRoll, numberRoll]);

	return (
		<span onClick={onClick} style={{cursor: "pointer"}}>
			{displayNumber} Numbers&trade;
		</span>
	);
};

*/
