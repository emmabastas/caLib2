/**
* This module defines the notion of a $(LATTICE). A $(LATTICE) is the
* data structure in wich all the $(I cells) are stored. Each generation,
* a $(RULE) changes the cells in the $(LATTICE). The most common example
* of a $(LATTICE) is a infinite square grid. Each square is the $(I cell) and it
* can contain any data such as a number or color. All of the $(I cells) then
* have a x,y coordinates associated with them. But some $(LATTICE)s can have
* other $(I dimensions), like a 3-dimensional grid of cubes where each cube have an
* x,y,z coordinate. Or it can have som other shape, like a grid with hexagons
* instead of squares. The only limitation is that the coordinates must be integers.
*
* This module provides templates for testing whether a given object is a $(LATTICE),
* and what kind of $(LATTICE) it is.
*
* $(CALIB_ABSTRACT_DESC)
*
* Macros:
* IS_ANY = 
*     Tests if something is a $(B $0).
*     $(DDOC_BLANKLINE)
*     returns $(DDOC_BACKQUOTED true) if $(DDOC_BACKQUOTED T) is a $(B $0). of
*     any $(I dimension), Storing any type of cells.
*     $(DDOC_BLANKLINE)
*     This template is the same as $(B is$0) but the $(I dimension) and type
*     of cells need not be specified. Refer to $(B is$0) for more details about
*     what a $(B $0) is.
*     $(DDOC_BLANKLINE)
*     $(DDOC_PARAMS T type to be tested)
*     $(DDOC_RETURNS $(B true) if $(B T) is any $(B $0), $(B false) if not)
*/

module caLib_abstract.lattice;

import std.meta : Repeat;
import caLib_abstract.util : hasCellStateType, hasDimension, hasNeighbourhoodType;
import caLib_abstract.neighbourhood : isNeighbourhood;



/**
* Tests if something is a $(B Lattice).
*
* returns `true` if `T` is a $(B Lattice) of $(I dimension) `N`, Storing cells of type `Ct`.
*
* A $(B Lattice) is the most basic form of a $(LATTICE). 
* It must define the functions: $(BR)
* `Ct get(string)(Coord)`, `Ct get(Coord)`, $(BR)
* `void set(string)(Coord, Ct)`, `void set(Coord, Ct)`, $(BR)
* `Ct[] getNeighbours(string)(Coord)`, `Ct[] getNeighbours(Coord)`, $(BR)
* `void iterate(string)(void delegate(Coord position))`, `void iterate(void delegate(Coord position))`, $(BR)
* `void nextGen(string)()`, `void nextGen()`, $(BR)
* Where `Coord` is an alias for a typetuple containing `int`'s, one `int` for each
* $(I dimension) (in a 3 dimensional $(B Lattice) `Coord` would be: `(int, int, int)`).
*
* Params:
*     T  = type to be tested
*     Ct = type of the cells the $(B Lattice) should contain
*     N  = number of dimensions
*
* Returns: true if T is a $(B Lattice), false if not
*/
template isLattice(T, Ct, uint N)
{
    alias Coord = Repeat!(N, int);

    static if(hasCellStateType!T && hasDimension!T && hasNeighbourhoodType!T)
    {
        enum isLattice =
            T.Dimension == N &&
            is(T.CellStateType : Ct) &&
            isNeighbourhood!(T.NeighbourhoodType, N) &&
            is(typeof(T.init.get!"_test"(Coord.init)) : Ct) &&
            is(typeof(T.init.get(Coord.init)) : Ct) &&
            is(typeof(T.init.set!"_test"(Coord.init, Ct.init)) : void) &&
            is(typeof(T.init.set(Coord.init, Ct.init)) : void) &&
            is(typeof(T.init.getNeighbours!"_test"(Coord.init)) : Ct[]) &&
            is(typeof(T.init.getNeighbours(Coord.init)) : Ct[]) &&
            is(typeof(T.init.iterate!"_test"((Coord c) {})) : void) &&
            is(typeof(T.init.iterate((Coord c) {})) : void) &&
            is(typeof(T.init.nextGen!"_test"()) : void) &&
            is(typeof(T.init.nextGen()) : void);   
    }
    else
    {
        enum isLattice = false;
    }
    
}

unittest
{
    static assert( isLattice!(Lattice!(int, 1), int, 1));
    static assert( isLattice!(Lattice!(int, 2), int, 2));
    static assert( isLattice!(Lattice!(int, 3), int, 3));

    static assert(!isLattice!(Lattice!(int, 3), uint, 2));
    static assert(!isLattice!(Lattice!(int, 1), uint, 1));
}



///$(IS_ANY Lattice)
template isAnyLattice(T)
{
    static if(hasCellStateType!T && hasDimension!T)
        enum isAnyLattice = isLattice!(T, T.CellStateType, T.Dimension);
    else
        enum isAnyLattice = false;
}

unittest
{
    static assert( isAnyLattice!(Lattice!(char, 1)));
    static assert( isAnyLattice!(BoundedLattice!(float, 2)));
    static assert(!isAnyLattice!string);
}



/**
* Tests if something is a $(B BoundedLattice). 
*
* returns `true` if `T` is a $(B BoundedLattice) of $(I dimension) `N`, Storing cells of type `Ct`.
* False if not.
*
* A $(B BoundedLattice) is a $(LATTICE) with a fixed size. It's function `getLatticeBounds`
* returns a list of `uint`'s representing the length of the $(I lattice's) $(I dimensions)
*
* A $(B BoundedLattice) is a $(B Lattice) with the additional function: `void getLatticeBounds()`.
*
* Params:
*     T  = type to be tested
*     Ct = type of the cells the $(B BoundedLattice) should contain
*     N  = number of dimensions
*
* Returns: true if T is a $(B BoundedLattice), false if not
*/
template isBoundedLattice(T, Ct, uint N)
{
    alias Coord = Repeat!(N, int);

    enum isBoundedLattice =
        isLattice!(T, Ct, N) &&
        is(typeof(T.init.getLatticeBounds()) : uint[N]);
}

unittest
{
    static assert( isLattice!(BoundedLattice!(int, 1), int, 1));
    static assert( isLattice!(BoundedLattice!(int, 2), int, 2));
    static assert( isLattice!(BoundedLattice!(int, 3), int, 3));
    static assert( isBoundedLattice!(BoundedLattice!(int, 1), int, 1));
    static assert( isBoundedLattice!(BoundedLattice!(int, 2), int, 2));
    static assert( isBoundedLattice!(BoundedLattice!(int, 3), int, 3));

    static assert(!isBoundedLattice!(BoundedLattice!(int, 3), uint, 2));
    static assert(!isBoundedLattice!(BoundedLattice!(int, 1), uint, 1));
}



///$(IS_ANY BoundedLattice)
template isAnyBoundedLattice(T)
{
    static if(hasCellStateType!T && hasDimension!T)
        enum isAnyBoundedLattice = isBoundedLattice!(T, T.CellStateType, T.Dimension);
    else
        enum isAnyBoundedLattice = false;
}

unittest
{
    static assert(!isAnyBoundedLattice!(Lattice!(char, 1)));
    static assert( isAnyBoundedLattice!(BoundedLattice!(float, 2)));
    static assert(!isAnyBoundedLattice!string);
}



version(unittest)
{
    import caLib_abstract.neighbourhood : Neighbourhood;

    struct Lattice(Ct, uint N)
    {
        alias CellStateType = Ct;
        alias NeighbourhoodType = Neighbourhood!Dimension;
        enum uint Dimension = N;

        alias Coord = Repeat!(N, int);

        Ct get(string s)(Coord) { return Ct.init; }
        Ct get(Coord) { return Ct.init; }

        void set(string s)(Coord, Ct) {}
        void set(Coord, Ct) {}

        Ct[] getNeighbours(string s)(Coord) { return new Ct[0]; }
        Ct[] getNeighbours(Coord) { return new Ct[0]; }

        void iterate(string s)(void delegate(Coord)) {}
        void iterate(void delegate(Coord)) {}

        void nextGen(string s)() {}
        void nextGen() {}
    }

    struct BoundedLattice(Ct, uint N)
    {
        Lattice!(Ct, N) lattice;
        alias lattice this;

        uint[N] getLatticeBounds() {
            // "return uint[N]"" makes compiler think
            // "uint[N]" is a call to "opIndex"
            uint[N] a; return a.init;
        }
    }
}