/**
* This module is contains utility templates used by the other modules in
* $(CALIB_ABSTRACT).
*
* Take a look the various modules in $(CALIB_ABSTRACT) for usage examples.
*/

module caLib_abstract.util;



template hasCellStateType(T)
{
	enum hasCellStateType =
		is(T.CellStateType) &&
		is(T.init.CellStateType);
}

unittest
{
	struct Foo {
		alias CellStateType = void;
	}

	static assert( hasCellStateType!Foo);
	static assert(!hasDimension!string);
}



template isCellStateTypesCompatible(T...)
{
	static assert(T.length != 0);

	static if(T.length == 1)
	{
		enum isCellStateTypesCompatible = true;
	}
	else
	{
		enum isCellStateTypesCompatible =
			__traits(compiles, (() {
						static assert(is(T[0] : T[1]));
					})() ) &&
			isDimensionsCompatible!(T[1..$]);
	}
}

unittest
{
	static assert( isCellStateTypesCompatible!(int));
	static assert( isCellStateTypesCompatible!(int, uint));
	static assert(!isCellStateTypesCompatible!(int, string));
}



template hasDisplayValueType(T)
{
	enum hasDisplayValueType =
		is(T.DisplayValueType) &&
		is(T.init.DisplayValueType);
}



template isDisplayValueTypesCompatible(T...)
{
	static assert(T.length != 0);

	static if(T.length == 1)
	{
		enum isCellStateTypesCompatible = true;
	}
	else
	{
		enum isCellStateTypesCompatible =
			__traits(compiles, (() {
						static assert(is(T[0] : T[1]));
					})() ) &&
			isDimensionsCompatible!(T[1..$]);
	}
}

unittest
{
	static assert( isCellStateTypesCompatible!(int));
	static assert( isCellStateTypesCompatible!(int, uint));
	static assert(!isCellStateTypesCompatible!(int, string));
}



template hasDimension(T)
{
	enum hasDimension =
		is(typeof(T.Dimension) : int) &&
		is(typeof(T.init.Dimension) : int);
}

unittest
{
	struct Foo {
		static immutable int Dimension = 0;
	}

	static assert( hasDimension!Foo);
	static assert(!hasDimension!int);
}



template isDimensionsCompatible(T...)
{
	static assert(T.length != 0);

	static if(T.length == 1)
	{
		enum isDimensionsCompatible = true;
	}
	else
	{
		enum isDimensionsCompatible =
			__traits(compiles, (() {
						static assert(T[0] == T[1]);
					})() ) &&
			isDimensionsCompatible!(T[1..$]);
			
	}
}

unittest
{
	static assert( isDimensionsCompatible!(0));
	static assert( isDimensionsCompatible!(0, 0u));
	static assert( isDimensionsCompatible!(0, 0u, byte(0)));
	static assert(!isDimensionsCompatible!(0, 0.1f));
}



template hasNeighbourhoodType(T)
{
	enum hasNeighbourhoodType =
		is(T.NeighbourhoodType) &&
		is(T.init.NeighbourhoodType);
}

unittest
{
	pragma(msg, "no unittest for template hasNeighbourhood in util.d");
}