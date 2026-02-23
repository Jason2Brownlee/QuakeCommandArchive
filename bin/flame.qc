/*
============================================================================

Quake Flamethrower 1.0

Another groovy patch from Quake Command - http://www.nuc.net/quake

QC Code By : Steve Bond         wedge@nuc.net

Apologies in advance... I was unable to comment this as well as I'd have
liked to. (I used some weird variable names - hope they don't cause problems.

============================================================================
*/

// Internal declaration
        void (vector fireorg) SpawnTouchFlame;
        void () BurnThem;

// Player.qc declaration
        void () DeathBubblesSpawn;



// Slightly varied version of DEATHBUBBLES
void(float num_bubbles, vector bub_origin) NewBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
        setorigin (bubble_spawner, bub_origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;

        if (self.classname == "player")
                bubble_spawner.owner = self;
        else
                bubble_spawner.owner = self.firewood;

        bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


/*
===============
BurnSelf 
===============
*/
void () BurnSelf =
{
        local entity    flame;

        flame = spawn ();
        flame.owner = self;
        flame.movetype = MOVETYPE_FLYMISSILE;
        flame.velocity = '0 0 75';
        flame.solid = SOLID_NOT;
        flame.classname = "fire";
        flame.origin = self.origin;
        self.onfire = TRUE;
        flame.firewood = self;
        flame.think = BurnThem;
        flame.nextthink = time;
        setmodel (flame, "progs/s_explod.spr");
        setsize (flame, '0 0 0', '0 0 0');            
};

/*
===============
Burn Them!
===============
*/
void () BurnThem =
{
        // CHECK FOR WATER *FIRST*
        if (self.firewood.waterlevel >= 1)
        {
                NewBubbles(6,self.firewood.origin);
                self.firewood.onfire = FALSE;
                self.firewood.effects = self.firewood.effects - EF_DIMLIGHT;
                remove(self);
                return;
        }
        else if (self.firewood.health > 0)
        {
                SpawnTouchFlame(self.firewood.origin);
                T_Damage (self.firewood, self, self.owner, 1);
                self.nextthink = time + 0.25;
        }
        else if (self.firewood.health <= 0)
                self.firewood.effects = self.firewood.effects - EF_DIMLIGHT;
};


/*
================
SpawnTouchFlame
================
*/

void (vector fireorg) SpawnTouchFlame =
{
        local entity    flame;
        local   float   rn;

        flame = spawn ();
        flame.owner = self;
        flame.movetype = MOVETYPE_FLYMISSILE;
        flame.velocity = '0 0 75';
        flame.solid = SOLID_NOT;
        flame.classname = "fire";
        flame.origin = fireorg;
        flame.think = s_explode1;
        flame.nextthink = time;
        setmodel (flame, "progs/s_explod.spr");
        setsize (flame, '0 0 0', '0 0 0');            
};

/*
================
FlameTouch
================
*/
void () FlameTouch =
{
        local   float   rn;

        if (other == self.owner)
                return;

        if (other.takedamage)
        {
                rn = random();
                // 20% chance
                if (rn <= 0.2 && !other.onfire)
                {
                        // Fire stays with whatever it hits
                        if (other.classname == "player")
                        {
                                centerprint(other,"You are on fire! Find WATER!\n");
                                stuffcmd (other,"bf\n");
                        }
                        other.onfire = TRUE;
                        self.firewood = other;
                        self.think = BurnThem;
                        self.nextthink = time;
                        self.solid = SOLID_NOT;
                        setmodel (self,"");
                        other.effects = other.effects | EF_DIMLIGHT;
                }
                else
                {
                        SpawnTouchFlame(other.origin);
                        T_Damage (other, self, self.owner, 10 );
                        remove (self);
                }
        }
        else if (other.classname == "worldspawn")
        {
                self.velocity = '0 0 0';
        }
};

/*
================
W_FireFlame
================
*/
void() W_FireFlame =
{
        local   entity flame;
        local   float rn;

        if (self.waterlevel > 2)
        {
                makevectors (self.v_angle);
                NewBubbles(2, self.origin+v_forward*64);

                rn = random();
                if (rn < 0.5)
                        sound (self, CHAN_WEAPON, "misc/water1.wav", 1, ATTN_NORM);
                else
                        sound (self, CHAN_WEAPON, "misc/water2.wav", 1, ATTN_NORM);

                return;
        }

        // Take away a shell
        self.currentammo = self.ammo_shells = self.ammo_shells - 1;

        sound (self, CHAN_WEAPON, "hknight/hit.wav", 1, ATTN_NORM);

        flame = spawn ();
        flame.owner = self;
        flame.movetype = MOVETYPE_FLYMISSILE;
        flame.solid = SOLID_BBOX;
        flame.classname = "fire";
		
// set flame speed    

	makevectors (self.v_angle);

                flame.velocity = aim(self, 10000);
                flame.velocity = flame.velocity * 300;

        flame.touch = FlameTouch;
	
        flame.think = s_explode1;
        flame.nextthink = time + 0.15;

        setmodel (flame, "progs/s_explod.spr");
        setsize (flame, '0 0 0', '0 0 0');            
        setorigin (flame, self.origin + v_forward * 16 + '0 0 16');
};
