/*========================================================================

Eject.qc - 8/14/96 Steve Bond (wedge)

========================================================================*/


void() shell_touch;

/*
===============
eject_shell

Spews a spent shell casing from a shotgun
===============
*/
void(vector org,vector dir) eject_shell =
{
        local float     flip;

        // Spawn one shell
	newmis = spawn ();
	newmis.owner = self;
        newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
        newmis.touch = shell_touch;
        newmis.classname = "shellcasing";
	newmis.think = SUB_Remove;
        newmis.nextthink = time + 20;
        setmodel (newmis, "progs/shelcase.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	setorigin (newmis, org);

        // pick a random number
        flip = random();
        

        // Based on that number, pick a velocity
        if (flip < 0.2 )
        newmis.velocity = '75 20 150';

        else if (flip < 0.4)
        newmis.velocity = '50 50 80';

        else if (flip < 0.6)
        newmis.velocity = '10 25 200';

        else if (flip < 0.8)
        newmis.velocity = '75 50 100';

        else
        newmis.velocity = '40 10 75';

        // pick a random number
        flip = random();

        // based on that rate, pick a rate at which to spin
        if (flip < 0.25)
        newmis.avelocity = '300 300 300';

        else if (flip < 0.5)
        newmis.avelocity = '150 300 100';

        else if (flip < 0.75)
        newmis.avelocity = '200 100 0';

        else
        newmis.avelocity = '400 200 100';
};




void() shell_touch =
{
     // DO NOT play the sound if we hit a door.
     if (other.classname == "door")
        return;

     sound (self, CHAN_WEAPON, "weapons/shellhit.wav", 1, ATTN_NORM);
};


