/**
* Returns the <code>double</code> value corresponding to a given
* bit representation.
* The argument is considered to be a representation of a
* floating-point value according to the IEEE 754 floating-point
* "double format" bit layout.
* <p>
* If the argument is <code>0x7ff0000000000000L</code>, the result 
* is positive infinity. 
* <p>
* If the argument is <code>0xfff0000000000000L</code>, the result 
* is negative infinity. 
* <p>
* If the argument is any value in the range
* <code>0x7ff0000000000001L</code> through
* <code>0x7fffffffffffffffL</code> or in the range
* <code>0xfff0000000000001L</code> through
* <code>0xffffffffffffffffL</code>, the result is a NaN.  No IEEE
* 754 floating-point operation provided by Java can distinguish
* between two NaN values of the same type with different bit
* patterns.  Distinct values of NaN are only distinguishable by
* use of the <code>Double.doubleToRawLongBits</code> method.
* <p>
* In all other cases, let <i>s</i>, <i>e</i>, and <i>m</i> be three 
* values that can be computed from the argument: 
* <blockquote><pre>
* int s = ((bits &gt;&gt; 63) == 0) ? 1 : -1;
* int e = (int)((bits &gt;&gt; 52) & 0x7ffL);
* long m = (e == 0) ?
*                 (bits & 0xfffffffffffffL) &lt;&lt; 1 :
*                 (bits & 0xfffffffffffffL) | 0x10000000000000L;
* </pre></blockquote>
* Then the floating-point result equals the value of the mathematical 
* expression <i>s</i>&middot;<i>m</i>&middot;2<sup><i>e</i>-1075</sup>.
*<p>
* Note that this method may not be able to return a
* <code>double</code> NaN with exactly same bit pattern as the
* <code>long</code> argument.  IEEE 754 distinguishes between two
* kinds of NaNs, quiet NaNs and <i>signaling NaNs</i>.  The
* differences between the two kinds of NaN are generally not
* visible in Java.  Arithmetic operations on signaling NaNs turn
* them into quiet NaNs with a different, but often similar, bit
* pattern.  However, on some processors merely copying a
* signaling NaN also performs that conversion.  In particular,
* copying a signaling NaN to return it to the calling method
* may perform this conversion.  So <code>longBitsToDouble</code>
* may not be able to return a <code>double</code> with a
* signaling NaN bit pattern.  Consequently, for some
* <code>long</code> values,
* <code>doubleToRawLongBits(longBitsToDouble(start))</code> may
* <i>not</i> equal <code>start</code>.  Moreover, which
* particular bit patterns represent signaling NaNs is platform
* dependent; although all NaN bit patterns, quiet or signaling,
* must be in the NaN range identified above.
*
* @param   bits   any <code>long</code> integer.
* @return  the <code>double</code> floating-point value with the same
*          bit pattern.
*/
public static native double longBitsToDouble(long bits);
