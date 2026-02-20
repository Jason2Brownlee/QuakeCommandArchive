/*========================================================================

Eject.qc - 8/14/96 Steve Bond (wedge)

========================================================================*/

float() crandom;
void() shell_touch;

/*
===============
eject_shell

Spews a spent shell casing from a shotgun
===============
*/
void(vector org,vector dir, float punch, vector spread) eject_shell =
{
      local float     flip;
	local vector transform;

      	// Spawn one shell
	newmis = spawn ();
	newmis.owner = self;
      	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
      	newmis.touch = shell_touch;
      	newmis.classname = "shellcasing";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 8;
      	setmodel (newmis, "progs/shelcase.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	setorigin (newmis, org);

      	// pick a random number
	flip = crandom();
	spread_x = spread_x * flip; 
	flip = crandom();
	spread_y = spread_y * flip; 
	flip = crandom();
	spread_z = spread_z * flip; 

      	transform_x = dir_y + spread_x;
	transform_y = 0 - dir_x + spread_y;
	transform_z = dir_z + spread_z;  
      	newmis.velocity = transform*punch;

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
	// Wilbur added random_number so that chance element that
	// a sound is played. Done to reduce "packet overflow" occurence in 
	// coop and deathmatch.
 	local float random_number;

     	// DO NOT play the sound if we hit a door.
     	if (other.classname == "door")
        	return;
     	// Changed by Wilbur to CHAN_AUTO since this is
     	// not an important sound.			
	if (random() > 0.7)      	
		sound (self, CHAN_AUTO, "shellhit.wav", 1, ATTN_NORM);
	else
		return;
};


