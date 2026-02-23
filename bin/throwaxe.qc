/*==========================================================================
ThrowAxe.qc - Release 2.1

8/17/96 - Steve Bond (wedge@nuc.net) MDL by John Guthrie(choryoth@nuc.net)
==========================================================================*/

void() AxeTouch =
{
        local   float   clink;
        local   entity  stemp;

// Ignore axe's owner if the axe hasn't bounced yet.
        if (other == self.owner && self.num_bounces == 0)
                return;

// Make the axe tumble, set movetype to bounce
        self.avelocity = '300 300 300';
        self.movetype = MOVETYPE_BOUNCE;
//make the axes' bounding box larger so they are easier to pick up.
        setsize (self, '-1 -2 -3' , '1 2 3');

        if (other.classname == "player" && self.velocity == '0 0 0')
        {
                sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
                sprint(other,"You Got A Throwing Axe!\n");
                other.num_axes = other.num_axes + 1;

                self.currentammo = self.num_axes;
                W_SetCurrentAmmo ();

                stemp = self;
                self = other;
                W_SetCurrentAmmo();
                self = stemp;

                remove(self);
        }


        if (other.takedamage && self.velocity != '0 0 0')
        {
                // If the Axe hits them before it bounces, do 45 damage
                if (self.num_bounces == 0)
                {
                        spawn_touchblood (40);
                        SpawnChunk (self.origin,self.velocity);
                        other.punchangle_x = -20;
                        other.axhitme = 1;
                        T_Damage (other, self, self.owner, 40);
                }
                else
                {
                        // The axe has bounced, so do 8 damage
                        other.punchangle_x = -10;
                        spawn_touchblood (15);
                        self.velocity = self.velocity * -0.5;
                        other.axhitme = 1;
                        T_Damage (other, self, self.owner, 8);
                }
        }

        else

        {
                clink = random() * 2;
                if (clink <=1)
                sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
                else
                sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
        }

// Count the bounces.
        self.num_bounces = self.num_bounces + 1;
// If it has bounced more than 22 times, remove the axe.
// It is most likely stuck and causing an incredibly
// annoying noise.
        if (self.num_bounces > 22)
                SUB_Remove();
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

// set missile duration
        missile.nextthink = time + 600;
        missile.think = SUB_Remove;

        setmodel (missile, "throwaxe.mdl");
        setsize (missile, '0 0 0' , '0 0 0');
        setorigin (missile, self.origin + v_forward*2 + '0 0 16');
        missile.avelocity ='-500 0 0';
        missile.num_bounces = 0;

        self.num_axes = self.num_axes - 1;
        self.currentammo = self.num_axes;

        W_SetCurrentAmmo ();
};

