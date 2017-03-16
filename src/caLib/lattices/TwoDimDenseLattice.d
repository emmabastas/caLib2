module caLib.lattices.TwoDimDenseLattice;

import caLib_abstract.neighbourhood : isNeighbourhood;

import caLib_util.misc : mod;



auto create_TwoDimDenseLattice(Ct, Nt)(int width, int height, Nt* neighbourhood)
if(isNeighbourhood!(Nt, 2))
in
{ assert(width >= 0 && height >= 0); }
body
{
    return create_TwoDimDenseLattice(width, height, neighbourhood, 0, 0);
}



auto create_TwoDimDenseLattice(Ct, Nt)(int width, int height, Nt* neighbourhood,
    Ct emptyCellState, Ct initialCondition)
if(isNeighbourhood!(Nt, 2))
in
{ assert(width >= 0 && height >= 0); }
body
{
    return create_TwoDimDenseLattice(width, height, neighbourhood,
        emptyCellState, (int x, int y) { return initialCondition; });
}



auto create_TwoDimDenseLattice(Ct, Nt)(int width, int height, Nt* neighbourhood,
    Ct emptyCellState, Ct delegate(int x, int y) initialCondition)
if(isNeighbourhood!(Nt, 2))
in
{ assert(width >= 0 && height >= 0); }
body
{
    return new TwoDimDenseLattice!(Ct, Nt)(width, height, neighbourhood,
        emptyCellState, initialCondition);
}



struct TwoDimDenseLattice(Ct, Nt)
if(isNeighbourhood!(Nt, 2))
{
    /*
    * get behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *
    * set behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *     "instant"
    *     "instant, torus"
    *     "instant, bounded"
    *     "instant, bounded-assumeInBounds"
    *
    * getNeighbours behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *
    * iterate behaviours
    *     "all"
    *
    * nextGen behaviours
    *     "correct"
    *     "toggle"
    *     "flipp"
    *     "nothing"
    */

private: 

    Nt* neighbourhood;

    int width;
    int height;

    Ct[] a, b;
    Ct[]* lattice, latticeNextGen;

    Ct emptyCellState;

public: 



    alias CellStateType = Ct;
    alias NeighbourhoodType = Nt;
    enum uint Dimension = 2;



    this(int width, int height, Nt* neighbourhood, Ct emptyCellState, Ct delegate(int x, int y) initialCondition)
    in
    { assert(width > 0 && height > 0); }
    body
    {
        this.width = width;
        this.height = height;

        this.neighbourhood = neighbourhood;

        this.emptyCellState = emptyCellState;

        a.length = width * height;
        b.length = width * height;
        lattice = &a;
        latticeNextGen = &b;

        for(int row=0; row<height; row++) {
            for(int col=0; col<width; col++) {
                lattice[0][row * width + col] = initialCondition(col, row);
            }
        }
    }



    Ct get(string behaviour)(int x, int y)
    {
        static if(behaviour == "torus")
        {
            return lattice[0].ptr[mod(y, height) * width + mod(x, width)];
        }
        else static if(behaviour == "bounded")
        {
            if(x >= 0 && x < width && y >= 0 && y < height)
            {
                return lattice[0].ptr[y * width + x];
            }
            else
            {
                return emptyCellState;
            }
        }
        else static if(behaviour == "bounded-assumeInBounds")
        {
            return lattice[0].ptr[y * width + x];
        }
        else static if(behaviour == "_test")
        {
            return Ct.init;
        }
        else
        {
            static assert(0, "TwoDimDenseLattice get method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }



    Ct get(int x, int y)
    {
        return get!"bounded"(x, y);
    }



    void set(string behaviour)(int x, int y, Ct newValue)
    {
        static if(behaviour.length >= 9 && behaviour[0 .. 9] == "instant, ")
        {
            immutable string behaviour = behaviour[9 .. behaviour.length];
            alias latticeNextGen = lattice;
        }
        else static if(behaviour == "instant")
        {
            immutable string behaviour = "bounded";
            alias latticeNextGen = lattice;
        }

        static if(behaviour == "torus")
        {
            latticeNextGen[0].ptr[mod(y, height) * width + mod(x, width)] = newValue;
        }
        else static if(behaviour == "bounded")
        {
            if(x >= 0 && x < width && y >= 0 && y < height)
            {
                latticeNextGen[0].ptr[y * width + x] = newValue;
            }
        }
        else static if(behaviour == "bounded-assumeInBounds")
        {
            latticeNextGen[0].ptr[y * width + x] = newValue;
        }
        else static if(behaviour == "instant")
        {
            if(x >= 0 && x < width && y >= 0 && y < height)
            {
                lattice[0].ptr[y * width + x] = newValue;
            }
        }
        else static if(behaviour == "_test")
        {}
        else
        {
            static assert(0, "TwoDimDenseLattice set method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }



    void set(int x, int y, Ct newValue)
    {
        set!"bounded"(x, y, newValue);
    }



    Ct[] getNeighbours(string behaviour)(int x, int y)
    {
        static if(behaviour == "torus"
               || behaviour == "bounded"
               || behaviour == "bounded-assumeInBounds")
        {
            Ct[] neighbours;
            foreach(coord ; neighbourhood.getNeighboursCoordinates(x, y))
            {
                neighbours ~= [get!behaviour(coord[0], coord[1])];
            }
            return neighbours;
        }
        else static if(behaviour == "_test")
        {
            return Ct[].init;
        }
        else
        {
            static assert(0, "TwoDimDenseLattice getNeighbours method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }



    Ct[] getNeighbours(int x, int y)
    {
        return getNeighbours!"bounded"(x, y);
    }



    void iterate(string behaviour)(void delegate(int x, int y) iterator)
    {
        static if(behaviour == "all")
        {
            for(int row=0; row<height; row++) {
                for(int col=0; col<width; col++) {
                    iterator(col, row);
                }
            }
        }
        else static if(behaviour == "_test")
        {}
        else
        {
            static assert(0, "TwoDimDenseLattice iterate method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }



    void iterate(void delegate(int x, int y) iterator)
    {
        iterate!"all"(iterator);
    }



    void nextGen(string behaviour)()
    {
        static if(behaviour == "correct")
        {
            Ct[]* tmp = lattice;
            lattice = latticeNextGen;
            latticeNextGen = tmp;

            for(int i=0; i<width*height; i++)
            {
                latticeNextGen[0].ptr[i] = emptyCellState;
            }
        }
        else static if(behaviour == "toggle")
        {
            lattice[0] = latticeNextGen[0].dup;
        }
        else static if(behaviour == "flipp")
        {
            Ct[]* tmp = lattice;
            lattice = latticeNextGen;
            latticeNextGen = tmp;
        }
        else static if(behaviour == "nothing")
        {}
        else static if(behaviour == "_test")
        {}
        else
        {
            static assert(0, "TwoDimDenseLattice nextGen method dosen't have a \""
                ~ behaviour ~"\" behaviour");
        }
    }

    void nextGen()
    {
        nextGen!"correct"();
    }

    uint[2] getLatticeBounds()
    {
        return [width, height];

    }
}



version(unittest)
{
    import caLib_abstract.lattice : isLattice;
    import caLib_abstract.neighbourhood : Neighbourhood;
}



unittest
{
    alias Lattice = TwoDimDenseLattice!(int, Neighbourhood!2);
    static assert( isLattice!(Lattice, int, 2));
}