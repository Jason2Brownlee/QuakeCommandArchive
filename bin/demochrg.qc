/*

DEMCHARGE.QC V1.0

8/6/96 Steve Bond   - wedge@nuc.net
Visit QUAKE COMMAND - http://www.nuc.net/quake

To recompile this source code, place it in the PROGS directory with
the rest of the .QC files and add DEMOCHRG.QC just below WEAPONS.QC in
the progs.src file. You must also add the following lines to WEAPONS.QC:

Place these two lines at the top of weapons.qc, with the rest of the
declarations

        void() W_PlantCharge;
        void() ChargeDet;



Place these lines in with the rest of the IMPULSE commands (I'm assuming
you have general knowledge of QuakeC if you are reading this)

        if (self.impulse == 32)
                W_PlantCharge ();
        if (self.impulse == 33)
                ChargeDet ();
*/

/*=======================================================================
This is the code segment that makes the demo charge explode and do damage
=======================================================================*/
void() ChargeExplode =
{
// Do radius damage
        self.solid = SOLID_NOT;
	T_RadiusDamage (self, self.owner, 120, world);
// Inform the network
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
// Draw the explosion
	setmodel (self, "progs/s_explod.spr");
	s_explode1 ();
};

/*========================================================================
ChargeDet is the functionthat is called when the signal to detonate is sent.
Only charges within a certain range of the owner will explode.
========================================================================*/
void() ChargeDet =
{
        local entity    head;
        // only charges within 2000 units of the signal will blow up
        head = findradius (self.origin, 2000);

        // Loop through every entity found within 2000 units of the player.
        // if they are of class "democharge" and belong to said player, blow
        // them up.
        while(head)
        {
                if( (head.classname == "democharge") && (head.owner == self) )
                   head.nextthink = time;
                head = head.chain;
        }
};

/*===================================================================
The CHARGETOUCH function is called when the charge touches another
object.
====================================================================*/
void() ChargeTouch =
{
        // Did a player touch a charge that was sitting on the floor
        // or wall?
        if (other.classname == "player" && self.velocity == '0 0 0')
                {
                // If so, they pick up the charge, and it is theirs.
                sprint (other, "You got a Demo Charge. (3 Grenades)\n");
                sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
                other.ammo_rockets = other.ammo_rockets + 3;
                W_SetCurrentAmmo ();
                remove(self);
                }

        if (other == self.owner) // Did the Charge hit it's thrower?
                // If so, ignore him.
                return;

        if (other.takedamage) // Did we hit something 'live'?
                // If so, make a different tink noise.
                {
                sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
                return;
                }

        if (other.classname != "worldspawn")
                {
                sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
                }
        // If all else fails, just make the bounce sound.
        if (other.classname == "worldspawn")
                {
                self.velocity = '0 0 0';
                self.avelocity = '0 0 0';
                self.movetype = MOVETYPE_NONE;
                sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
                }
};

/*
================
W_PlantCharge
================
*/
void() W_PlantCharge =
{
        if (self.isfeign)       // Feign: Experimental
                return;
	
	local   entity item;
	
// Does the player have at least 3 rockets?
        if (self.ammo_rockets < 3)
// If not, no Demo Charge for him! Just return
                return;

// Take the 6 rockets away from the player
        self.currentammo = self.ammo_rockets = self.ammo_rockets - 3;

// Make this sound when the pipebomb is thrown (currently disabled)
        sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);

// This makes the screen shake about an axis, simulating 'kick'
        self.punchangle_x = -2;

// Spawn the Demo Charge
        item = spawn ();
        item.owner = self;
        item.movetype = MOVETYPE_TOSS;
        item.solid = SOLID_TRIGGER;
        item.classname = "democharge";
        item.ammo_rockets = 3;

// set the pipebomb's speed and direction
	makevectors (self.v_angle);

	if (self.v_angle_x)
                item.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
                item.velocity = aim(self, 10000);
                item.velocity = item.velocity * 600;
                item.velocity_z = 200;
	}


// Make the Charge tumble in flight.
        //item.avelocity = '300 300 300';

        item.angles = vectoangles(item.velocity);
	
// If it touches anything(one), go to ChargeTouch
        item.touch = ChargeTouch;

        item.think = ChargeExplode;

// Lifespan of five minutes in case something goes wrong. 
        item.nextthink = time + 300;

        setmodel (item, "progs/charge2.mdl");
        setsize (item, '0 0 0', '0 0 0');            
        setorigin (item, self.origin);

// Wait one full second before you can throw another.
        self.attack_finished = time + 1;
        W_SetCurrentAmmo ();
};

