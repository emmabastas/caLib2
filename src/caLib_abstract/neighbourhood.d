/**
* This module defines the notion of a $(NEIGHBOURHOOD). A $(NEIGHBOURHOOD)
* defines what cells in the lattice that are "neighbours". Most ca $(RULE)s
* change the state of a $(I cell) depending on the $(I cells) $(I neighbours).
*
* It provides templates for testing whether a given object is a $(NEIGHBOURHOOD),
* and what kind of $(NEIGHBOURHOOD) it is.
*
* $(CALIB_ABSTRACT_DESC)
*
* Macros:
* IS_ANY = 
*     Tests if something is a $(B $0).
*     $(DDOC_BLANKLINE)
*     returns $(DDOC_BACKQUOTED true) if $(DDOC_BACKQUOTED T) is a $(B $0). of
*     any dimension.
*     $(DDOC_BLANKLINE)
*     This template is the same as $(B is$0) but the dimension need not be
*     specified. Refer to $(B is$0) for more details about what a $(B $0) is.
*     $(DDOC_BLANKLINE)
*     $(DDOC_PARAMS T type to be tested)
*     $(DDOC_RETURNS $(B true) if $(B T) is any $(B $0), $(B false) if not)
*/

module caLib_abstract.neighbourhood;

import std.meta : Repeat;
import caLib_abstract.util : hasDimension, isDimensionsCompatible;



/**
* Tests if something is a $(B Neighbourhood).
*
* returns `true` if `T` is a $(B Neighbourhood) of dimension `N`.
*
* A $(B Neighbourhood) is the most basic form of a $(NEIGHBOURHOOD).
* It's `getNeighboursCoordinates` function takes a $(I cells) position
* and returns a list of coordinate pairs for it's neighbours positions. 
*
* It must define the primitive: $(BR)`int[N][] getNeighboursCoordinates(Coord)`. $(BR)
* Where N is the dimension of the $(B Neighbourhood) and `Coord` is an 
* alias for a typetuple containing `int`'s, one `int` for each
* dimension (in a 3 dimensional $(B Neighbourhood) `Coord` would be: `(int, int, int)`).
*
* Params:
*     T  = type to be tested
*     N  = number of dimensions
*
* Returns: true if T is a $(B Neighbourhood), false if not
*/

template isNeighbourhood(T, uint N)
{
    alias Coord = Repeat!(N, int);

    static if(hasDimension!T)
    {
    	enum isNeighbourhood =
	    	isDimensionsCompatible!(T.Dimension, N) &&
	        is(typeof(T.init.getNeighboursCoordinates(Coord.init)) : int[N][]);
    }
    else
    {
    	enum isNeighbourhood = false;
    }
}

///
unittest
{
	struct A {
		enum uint Dimension = 2;
		int[2][] getNeighboursCoordinates(int x, int y) {
			return [[x+1, y+1], [x+1, y], [x+1, y-1]];
		}
	}

	static assert( isNeighbourhood!(A, 2));
	static assert(!isNeighbourhood!(string, 1));
}

unittest
{
	static assert( isNeighbourhood!(Neighbourhood!(1), 1));
	static assert( isNeighbourhood!(Neighbourhood!(2), 2));
	static assert( isNeighbourhood!(Neighbourhood!(3), 3));

	static assert(!isNeighbourhood!(Neighbourhood!(3), 2));
}



///$(IS_ANY Neighbourhood)
template isAnyNeighbourhood(T)
{
	static if(hasDimension!T)
		enum isAnyNeighbourhood = isNeighbourhood!(T, T.Dimension);
	else
		enum isAnyNeighbourhood = false;
}

///
unittest
{
	struct Foo {
		enum uint Dimension = 2;

		int[Dimension][] getNeighboursCoordinates(int x, int y) {
			return [[x+1, y+1], [x+1, y], [x+1, y-1]];
		}
	}

	static assert(!   isNeighbourhood!(Foo, 3));
	static assert( isAnyNeighbourhood!(Foo   ));
}

unittest
{
	static assert( isAnyNeighbourhood!(Neighbourhood!(1)));
    static assert( isAnyNeighbourhood!(StaticNeighbourhood!(2)));
    static assert( isAnyNeighbourhood!(ShiftingNeighbourhood!(3)));
    static assert(!isAnyNeighbourhood!string);
}



/**
* Tests if something is a $(B StaticNeighbourhood).
*
* returns `true` if `T` is a $(B StaticNeighbourhood) of dimension `N`.
*
* A $(B StaticNeighbourhood) is a $(NEIGHBOURHOOD) that never changes.
* If a particular $(I cell) has a particular $(I neighbour) it will always have
* that $(I neighbour). Also, if a $(I cell) where to have a neighbour "to the right"
* all other $(I cells) will also have a neighbour "to the right".
* A $(B StaticNeighbourhood) dosen't really add any additional functionality.
* All it does is having the a uint enum NeighboursAmount.
*
* Params:
*     T  = type to be tested
*     N  = number of dimensions
*
* Returns: true if T is a $(B StaticNeighbourhood), false if not
*/
template isStaticNeighbourhood(T, uint N)
{
	alias Coord = Repeat!(N, int);

    enum isStaticNeighbourhood =
        isNeighbourhood!(T, N) &&
        is(typeof(T.NeighboursAmount) : uint) &&
        is(typeof(T.init.NeighboursAmount) : uint);
}

///
unittest
{
	struct A {
		enum uint Dimension = 2;
		enum uint NeighboursAmount = 1;
		enum isStatic;
		int[2][] getNeighboursCoordinates(int x, int y) {
			return [[x+1, y+1]];
		}
	}

	static assert( isNeighbourhood!(A, 2));
	static assert( isStaticNeighbourhood!(A, 2));
	static assert(!isStaticNeighbourhood!(string, 1));
}

unittest
{
	static assert( isStaticNeighbourhood!(StaticNeighbourhood!(1), 1));
	static assert( isStaticNeighbourhood!(StaticNeighbourhood!(2), 2));
	static assert( isStaticNeighbourhood!(StaticNeighbourhood!(3), 3));

	static assert(!isStaticNeighbourhood!(StaticNeighbourhood!(3), 2));
	static assert(!isStaticNeighbourhood!(Neighbourhood!(1), 1));
}



///$(IS_ANY StaticNeighbourhood)
template isAnyStaticNeighbourhood(T)
{
	static if(hasDimension!T)
		enum isAnyStaticNeighbourhood = isStaticNeighbourhood!(T, T.Dimension);
	else
		enum isAnyStaticNeighbourhood = false;
}

///
unittest
{
	struct Foo {
		enum uint Dimension = 2;
		enum uint NeighboursAmount = 1;
		int[2][] getNeighboursCoordinates(int x, int y) {
			return [[x+1, y+1]];
		}
	}
	static assert(!   isStaticNeighbourhood!(Foo, 3));
	static assert( isAnyStaticNeighbourhood!(Foo   ));
}

unittest
{
	static assert(!isAnyStaticNeighbourhood!(Neighbourhood!(1)));
    static assert( isAnyStaticNeighbourhood!(StaticNeighbourhood!(2)));
    static assert(!isAnyStaticNeighbourhood!(ShiftingNeighbourhood!(3)));
    static assert(!isAnyStaticNeighbourhood!string);
}



/**
* Tests if something is a $(B ShiftingNeighbourhood).
*
* returns `true` if `T` is a $(B ShiftingNeighbourhood) of dimension `N`.
*
* A $(B ShiftingNeighbourhood) is a $(NEIGHBOURHOOD) that can change each
* generation. It's `shift` function is meant to be called by the $(I ca)'s
* $(LATTICE) every time a generation changes.
*
* A $(B ShiftingNeighbourhood) is a $(B neighbourhood) with the additional
* primitive `void shift()`
*
* Params:
*     T  = type to be tested
*     N  = number of dimensions
*
* Returns: true if T is a $(B ShiftingNeighbourhood), false if not
*/
template isShiftingNeighbourhood(T, uint N)
{
	enum isShiftingNeighbourhood = 
		isNeighbourhood!(T, N) &&
		is(typeof(T.init.shift()) : void);
}

///
unittest
{
	struct Foo {
		enum uint Dimension = 2;

		private bool state = false;

		int[2][] getNeighboursCoordinates(int x, int y) {
			if(state) {
				return [[x+1, y+1]];
			} else {
				return [[x-1, y-1]];
			}
		}

		void shift() { state = !state; }
	}

	static assert( isNeighbourhood!(Foo, 2));
	static assert( isShiftingNeighbourhood!(Foo, 2));
	static assert(!isShiftingNeighbourhood!(string, 1));
}

unittest
{
	static assert( isShiftingNeighbourhood!(ShiftingNeighbourhood!(1), 1));
	static assert( isShiftingNeighbourhood!(ShiftingNeighbourhood!(2), 2));
	static assert( isShiftingNeighbourhood!(ShiftingNeighbourhood!(3), 3));

	static assert(!isShiftingNeighbourhood!(ShiftingNeighbourhood!(3), 2));
	static assert(!isShiftingNeighbourhood!(Neighbourhood!(1), 1));
}



///$(IS_ANY ShiftingNeighbourhood)
template isAnyShiftingNeighbourhood(T)
{
	static if(hasDimension!T)
		enum isAnyShiftingNeighbourhood = isShiftingNeighbourhood!(T, T.Dimension);
	else
		enum isAnyShiftingNeighbourhood = false;
}

///
unittest
{
	struct Foo {
		enum uint Dimension = 2;

		private bool state = false;

		int[2][] getNeighboursCoordinates(int x, int y) {
			if(state) {
				return [[x+1, y+1]];
			} else {
				return [[x-1, y-1]];
			}
		}

		void shift() { state = !state; }
	}

	static assert(!   isShiftingNeighbourhood!(Foo, 3));
	static assert( isAnyShiftingNeighbourhood!(Foo   ));
}

unittest
{
	static assert( isAnyShiftingNeighbourhood!(ShiftingNeighbourhood!(1)));
    static assert( isAnyShiftingNeighbourhood!(ShiftingNeighbourhood!(2)));
    static assert( isAnyShiftingNeighbourhood!(ShiftingNeighbourhood!(3)));
    static assert(!isAnyShiftingNeighbourhood!(Neighbourhood!(1)));
    static assert(!isAnyShiftingNeighbourhood!string);
}



/+
+ This template is undocumented since it is unclear wheater it should exist or not
+/
template isBlockNeighbourhood(T, uint N)
{
	alias Coord = Repeat!(N, int);

	enum isBlockNeighbourhood =
		isNeighbourhood!(T, N) &&
		is(typeof(T.init.getBlockCoordinates(Coord.init)) : int[N][]); 
}

unittest
{
	static assert( isBlockNeighbourhood!(BlockNeighbourhood!(1), 1));
	static assert( isBlockNeighbourhood!(BlockNeighbourhood!(2), 2));
	static assert( isBlockNeighbourhood!(BlockNeighbourhood!(3), 3));

	static assert(!isBlockNeighbourhood!(BlockNeighbourhood!(3), 2));
}



version(unittest)
{
	struct Neighbourhood(uint N)
	{
		enum uint Dimension = N;

		alias Coord = Repeat!(N, int);

		int[N][] getNeighboursCoordinates(Coord) { int[N][]a; return a.init; }
	}

	struct StaticNeighbourhood(uint N)
	{
		Neighbourhood!N neighbourhood;
		alias neighbourhood this;

		enum uint NeighboursAmount = 0;
	}

	struct ShiftingNeighbourhood(uint N)
	{
		Neighbourhood!N neighbourhood;
		alias neighbourhood this;

		void shift() {}
	}

	struct BlockNeighbourhood(uint N)
	{
		alias Coord = Repeat!(N, int);

		Neighbourhood!N neighbourhood;
		alias neighbourhood this;

		int[N][] getBlockCoordinates(Coord) { int[N][]a; return a.init; }
	}
}