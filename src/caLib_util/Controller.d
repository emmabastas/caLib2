module caLib_util.Controller;

import caLib_abstract.lattice : isLattice;
import caLib_abstract.rule : isRule, isReversibleRule;
import caLib_abstract.renderer : isRenderer;
import derelict.sdl2.sdl;
import std.stdio: writeln;
import std.exception : Exception;



auto create_Controller(Lt, Rt, REt)(Lt* lattice, Rt* rule, REt* renderer)
{
    return new Controller!(Lt, Rt, REt)(lattice, rule, renderer);
}



class Controller(Lt, Rt, REt)
{

private:

    Lt* lattice;
    Rt* rule;
    REt* renderer;

    void delegate() task;
    bool running;
    bool recording;

    static if(isReversibleRule!Rt)
    {
        bool reverse;
    }

public:

    this(Lt* lattice, Rt* rule, REt* renderer)
    {
        this.lattice = lattice;
        this.rule = rule;
        this.renderer = renderer;

        this.task = null;
        this.running = false;
        this.recording = false;

        static if(isReversibleRule!Rt)
        {
            bool reverse = false;
        }
    }

    void start()
    {
        renderer.render();

        task = &this.pause;

        while(true)
        {
            SDL_Event events;
            while(SDL_PollEvent(&events))
            {
                if(events.type == SDL_QUIT)
                {
                    return;
                }
                else if(events.type == SDL_KEYDOWN)
                {
                    if(events.key.keysym.sym == SDLK_SPACE)
                    {
                        if(running)
                        {
                            task = &this.pause;
                            running = false;
                        }
                        else
                        {
                            task = &this.run;
                            running = true;
                        }
                    }
                    else if(events.key.keysym.sym == SDLK_d)
                    {
                        run();
                        task = &this.pause;
                        running = false;
                    }
                    else if(events.key.keysym.sym == SDLK_s)
                    {
                        screenshot();
                    }
                    else if(events.key.keysym.sym == SDLK_r)
                    {
                        record();
                    }
                    static if(isReversibleRule!Rt)
                    {
                        if(events.key.keysym.sym == SDLK_a)
                        {
                            reverse = !reverse;
                            writeln("running reverse");
                        }
                    }
                }
            }

            task();
        }
    }

    void pause() {}

    void run()
    {
        static if(isReversibleRule!Rt)
        {
            if(!reverse)
                rule.applyRule();
            else
                rule.applyRuleReverse();
        }
        else
        {
            rule.applyRule();
        }
        renderer.render();
    }

    void screenshot()
    {
        writeln("screenshoting. The programm might seem unresponsive");
        try
        {
            renderer.screenshot("screenshot.png");
            writeln("done screenshoting");
        }
        catch(Exception e)
        {
            writeln("could not screenshot. Error message:\n    ", e.msg);
        }
    }

    void record()
    {
        if(recording)
        {
            scope(exit) recording = false;
            try
            {
                renderer.stopRecording();
                writeln("done recording");
            }
            catch(Exception e)
            {
                writeln("could not complete recording. Error message:\n    ",
                    e.msg);
            }
        }
        else
        {
            try
            {
                renderer.startRecording("recording.mp4", 10);
                writeln("recording.. Press r to stop recording");
                recording = true;
            }
            catch(Exception e)
            {
                writeln("could not start recording. Error message:\n    ",
                    e.msg);

                recording = false;
            }
        }
    }
}