/*==========================================================================
ThrowAxe.qc

8/14/96 - Steve Bond (wedge@nuc.net)
==========================================================================*/

void() AxeTouch =
{

        local   float   clink;
        local   entity  stemp;

        if (self.velocity == '0 0 0')
        {
                self.movetype = MOVETYPE_NONE;
                self.avelocity = '0 0 0';
        }

        if (other.classname == "player" && self.velocity == '0 0 0')
        {
                sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
                sprint(other,"You Got The Throwing Axe!\n");
                other.num_axes = other.num_axes + 1;

                self.currentammo = self.num_axes;
                W_SetCurrentAmmo ();

                stemp = self;
                self = other;
                W_SetCurrentAmmo();
                self = stemp;

                remove(self);
        }

        if (other == self.owner)
                return;
        if (other.classname == "door")
        // return if  axe hits door
        {
                self.avelocity = '300 300 300';
                self.movetype = MOVETYPE_BOUNCE;
                return;
        }

	// If it has bounced more than twice remove its ability to hurt people 
        if (other.takedamage && self.velocity != '0 0 0' && self.num_bounces < 3)
        {
                // If the Axe hits them before it bounces, do 30 damage
                if (self.movetype != MOVETYPE_BOUNCE)
                {
                        spawn_touchblood (30);
                        SpawnChunk (self.origin,self.velocity);
                        other.velocity = self.velocity * 2;
                        other.axhitme = 1;
                        sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
                        T_Damage (other, self, self.owner, 30);
                }
                else
                {
                        // The axe has bounced, so do 15 damage
                        spawn_touchblood (15);
                        other.axhitme = 1;
			// Wilbur made the sound softer for bounced impacts
                        sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 0.75, ATTN_NORM);
                        T_Damage (other, self, self.owner, 15);
                }
        }
        else
        {
	  		if (self.movetype != MOVETYPE_BOUNCE)
                		{
					sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
     	          		}
                	else
                		{
        				sound (self, CHAN_WEAPON, "player/axhit2.wav", 0.5, ATTN_NORM);
		    		}
        }

        self.num_bounces = self.num_bounces + 1;

	// If it has bounced more than 22 times, remove the axe.
	// It is most likely stuck and causing an incredibly annoying noise.
        if (self.num_bounces > 22)
                SUB_Remove();

        if ( !(other.axhitme) )
        {
                self.avelocity = '300 300 300';
                self.movetype = MOVETYPE_BOUNCE;
        }
        else
        {
                self.avelocity = '30 30 30';
                self.velocity = '30 30 30';
                self.movetype = MOVETYPE_BOUNCE;
        }
};

void() W_ThrowAxe =
{
        local   entity missile;

        sound (self, CHAN_WEAPON, "woosh.wav", 1, ATTN_NORM);

        self.punchangle_x = -6;

	missile = spawn ();
	missile.owner = self;
        missile.movetype = MOVETYPE_FLYMISSILE;
        missile.solid = SOLID_TRIGGER;
	// set missile speed    
        makevectors (self.v_angle);
        missile.velocity = aim(self, 10000);
        missile.angles = vectoangles(missile.velocity);
        missile.velocity = missile.velocity * 600;
        missile.touch = AxeTouch;
	// set missile duration - Modified by Wilbur to 2 minutes
        missile.nextthink = time + 120;
        missile.think = SUB_Remove;
        setmodel (missile, "progs/throwaxe.mdl");
	//was   setsize (missile, '0 0 0', '0 0 0');  
        setsize (missile, '-1 -2 -3', '1 2 3');            
        setorigin (missile, self.origin + v_forward*2 + '0 0 16');

        missile.avelocity ='-500 0 0';

        self.num_axes = self.num_axes - 1;
        self.currentammo = self.num_axes;

        W_SetCurrentAmmo ();
};


