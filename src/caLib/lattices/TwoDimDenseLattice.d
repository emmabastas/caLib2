module caLib.lattices.TwoDimDenseLattice;

import caLib_abstract.neighbourhood : isNeighbourhood;
import caLib_abstract.util : formatBehaviour;
import caLib.neighbourhoods.TwoDimMooreNeighbourhood;

import caLib_util.misc : mod;
import std.algorithm.searching : canFind;



auto create_TwoDimDenseLattice(Ct, Nt)(int width, int height, Nt* neighbourhood)
if(isNeighbourhood!(Nt, 2))
in
{
    assert(width > 0 && height > 0);
    assert(neighbourhood !is null);
}
body
{
    return create_TwoDimDenseLattice(width, height, neighbourhood, 0, 0);
}



auto create_TwoDimDenseLattice(Ct, Nt)(int width, int height, Nt* neighbourhood,
    Ct emptyCellState, Ct initialCondition)
if(isNeighbourhood!(Nt, 2))
in
{
    assert(width > 0 && height > 0); 
    assert(neighbourhood !is null);
}
body
{
    return create_TwoDimDenseLattice(width, height, neighbourhood,
        emptyCellState, (int x, int y) { return initialCondition; });
}



auto create_TwoDimDenseLattice(Ct, Nt)(int width, int height, Nt* neighbourhood,
    Ct emptyCellState, Ct delegate(int x, int y) initialCondition)
if(isNeighbourhood!(Nt, 2))
in
{
    assert(width > 0 && height > 0);
    assert(neighbourhood !is null);
}
body
{
    return new TwoDimDenseLattice!(Ct, Nt)(width, height, neighbourhood,
        emptyCellState, initialCondition);
}



struct TwoDimDenseLattice(Ct, Nt) if(isNeighbourhood!(Nt, 2))
{

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

    this(int width, int height, Nt* neighbourhood, Ct emptyCellState,
        Ct delegate(int x, int y) initialCondition)
    in
    {
        assert(width > 0 && height > 0);
        assert(neighbourhood !is null);
    }
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

        foreach(row; 0 .. height)
        {
            foreach(col; 0 .. width)
            {
                lattice[0][row * width + col] = initialCondition(col, row);
            }
        }
    }



    Ct get(string behaviour)(int x, int y)
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "torus")
        {
            return lattice[0].ptr[mod(y, height) * width + mod(x, width)];
        }
        else static if(behaviour[0] == "bounded" 
            && behaviour.canFind("assumeInBounds"))
        {
            return lattice[0].ptr[y * width + x];
        }
        else static if(behaviour[0] == "bounded")
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
        else static if(behaviour[0] == "_test")
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
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour.canFind("instant")) {
            alias latticeToChange = lattice;
        } else {
            alias latticeToChange = latticeNextGen;
        }

        static if(behaviour[0] == "torus")
        {
            latticeToChange[0].ptr[mod(y, height) * width + mod(x, width)]
                = newValue;
        }
        else static if(behaviour[0] == "bounded"
            && behaviour.canFind("assumeInBounds"))
        {
            latticeToChange[0].ptr[y * width + x] = newValue;
        }
        else static if(behaviour[0] == "bounded")
        {
            if(x >= 0 && x < width && y >= 0 && y < height)
            {
                latticeToChange[0].ptr[y * width + x] = newValue;
            }
        }
        else static if(behaviour[0] == "_test")
        {

        }
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
        enum string behaviourString = behaviour;
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "torus"
               || behaviour[0] == "bounded")
        {
            Ct[] neighbours;
            foreach(coord ; neighbourhood.getNeighboursCoordinates(x, y))
            {
                neighbours ~= [get!behaviourString(coord[0], coord[1])];
            }
            return neighbours;
        }
        else static if(behaviour[0] == "_test")
        {
            return Ct[].init;
        }
        else
        {
            static assert(0, "TwoDimDenseLattice getNeighbours method dosen't" 
                "have a \"" ~ behaviour ~ "\" behaviour");
        }
    }



    Ct[] getNeighbours(int x, int y)
    {
        return getNeighbours!"bounded"(x, y);
    }



    void iterate(string behaviour)(Ct delegate(Ct cellState, Ct[] neighbours,
        int x, int y) rule)
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        // optimized for moore neighbourhood
        static if(behaviour[0] == "all" && is(Nt : TwoDimMooreNeighbourhood))
        {
            Ct[] neighbours;
            Ct cellState;
            Ct newCellState;
            foreach (x; 0 .. width)
            {
                neighbours = getNeighbours(x, 0);
                cellState = get!"bounded-assumeInBounds"(x, 0);
                foreach(y; 0 .. height)
                {
                    set(x, y, rule(cellState, neighbours, x, y));

                    newCellState = neighbours[6];
                    neighbours = [
                        neighbours[3], cellState,   neighbours[4],
                        neighbours[5],              neighbours[7],
                        get(x-1, y+2), get(x, y+2), get(x+1, y+2)];
                    cellState = newCellState;
                }
            }
        }
        // generic
        else static if(behaviour[0] == "all")
        {
            foreach(y; 0 .. height)
            {
                foreach(x; 0 .. width)
                {
                    set(x, y, rule(get(x, y), getNeighbours(x, y), x, y));
                }
            }
        }
        else static if(behaviour[0] == "_test")
        {

        }
        else
        {
            static assert(0, "TwoDimDenseLattice iterate method dosen't have a"
                ~ "\"" ~ behaviour ~"\" behaviour");
        }
    }



    void iterate(Ct delegate(Ct cellState, Ct[] neighbours,
        int x, int y) rule)
    {
        iterate!"all"(rule);
    }



    void nextGen(string behaviour)()
    {
        immutable string[] behaviour = formatBehaviour!behaviour;

        static if(behaviour[0] == "correct")
        {
            Ct[]* tmp = lattice;
            lattice = latticeNextGen;
            latticeNextGen = tmp;

            for(int i=0; i<width*height; i++)
            {
                latticeNextGen[0].ptr[i] = emptyCellState;
            }
        }
        else static if(behaviour[0] == "toggle")
        {
            lattice[0] = latticeNextGen[0].dup;
        }
        else static if(behaviour[0] == "flipp")
        {
            Ct[]* tmp = lattice;
            lattice = latticeNextGen;
            latticeNextGen = tmp;
        }
        else static if(behaviour[0] == "nothing")
        {}
        else static if(behaviour[0] == "_test")
        {}
        else
        {
            static assert(0, "TwoDimDenseLattice nextGen method dosen't have a"
                ~ "\"" ~ behaviour ~"\" behaviour");
        }
    }

    void nextGen()
    {
        nextGen!"correct"();
    }

    int[2] getLatticeBounds()
    out(result)
    {
        assert(result[0] > 0 && result[1] > 0);
    }
    body
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