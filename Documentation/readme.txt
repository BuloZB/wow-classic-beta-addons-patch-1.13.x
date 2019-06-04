Welcome to the YACL FAQ.

Q) Is YACL bugfree ?
A) Versions which are marked as stable should be bugfree (in theory),
   otherwise no. This is a noncommercial product that I do for fun. 
   So I assume its just fair, that all of you do the testing for
   me. Whenever you find a bug or strange behaviour, or even
   if you simply dislike something - tell me. Your feedback is
   needed. The more you tell me what you want, the better it
   will suit the needs of the masses.
   

Q) Why is the deathcounter for players not working ?
A) Because that is a known 2.4 Blizzard bug. It is announced to be 
   fixed in patch 2.4.2. Have a look into your normal combat log. 
   Your own death is not shown there.
   

Q) Why do I have the same spell multiple times in my detailed view,
   and they all have the same or no rank ?
A) Because that is a Blizzard bug. They do not deliver correct ranks
   for some kind of spells.


Q) Where is the option to merge pet with owners ?
A) There is no such option. The pets damage is automatically added to the
   owner in the big view. Therefore hunters and warlocks will have the right
   ranking in the list. On the other hand, pets are always shown seperately
   so one can see clearly the contribution of the pet. Detailed views are 
   also handled seperately for pets and owners (like it would simply be
   wrong to calculate the sum for critchances of owners and their pets).


Q) I used different pets during this fight ! Where are they in the combat log ?
A) All your pets are merged into one. The combat log shows only the latest pet,
   but it contains the summary of all previous pets also.


Q) What happens with stupid player and pet names ? (Like hunters that name their
   pets after themselves). What about water elementals ?
A) YACL does not look at names at all. It is build completely onto the 2.4 API
   and has a unique code for everything. It knows exactly who the owner of that
   elemental is, and even 3 "Boars" running in one Arena are not confusing it :)


Q) What about totems ?
A) Totems do not count as persons because they are so very much temporary.
   They are simply added to the owner as if they would be regular spells.


Q) Why can't I move my char with the cursor keys, while YACL is open ?
A) YACL grabs the cursor keys to scroll in the big window. If you do not
   like this function (like you are using cursor keys to move your char),
   disable it with "/yacl cursor off".


Q) How do I spam my reports into the chat ?
A) Open the chatline by pressing ENTER. Then Left-click onto the column header
   that you want to post.


Q) How do I change the amount of bargraph lines ?
A) Use the command "/yacl bars n" with n=[0..20] . Zero will disable the bargraphs.


Q) What commands are there for YACL ? 
A) Try "/yacl help".


Q) How is DPS calculated ?
A) By definition DPS is your damage divided by combat time : dps=D/T
   The damage D is a well known number. But with T things become tricky.
   And every damage meter has its own ways to calculate T.
   Some do the very trivial (and very wrong) way of assuming that T equals
   the time you are flagged for combat. Let's see why that is wrong.
   
   Test scenario 1:
   Little roxxor want's to check his DPS and he has choosen a level 1
   rabbit to be his victim. He is swinging his mighty weapon, and with a
   single strike he kills the poor rabbit. What we all see is a four digit 
   damage number , sure. But what was the duration of the fight ?
   In fact the duration was his weapon swing time, or his cast time if he used
   magic instad, or the global cooldown time, if he killed the rabbit with
   an instant spell.
   
   Test scenario 2:
   Now little roxxer isn't dealing so much damage, and he needs two strikes
   to kill the rabbit. The fight duration is obviously the pre-fight time to
   prepare the first strike plus the time between the second and the first strike.
   
   And that is basically the method YACL uses to calculate your fight time.
   In this way, the DPS value will show your damage potential.
   
   You might find people in your raid that show extremely high DPS numbers,
   but their overall damage is much lower than yours. The reason is simply,
   that those people aren't fighting the whole time. They probably went to the
   toilet for some time, or they were just fighting in appropriate situations.
   One example could be a mage who waits at the beginning of the bossfight and
   then shoots out all the mana he has in a single burst. Then he waits some time
   and does another burst. That would give much higher dps numbers than the same mage
   trying to fire spells with small pauses inbetween.
   
   As a matter of fact, YACL is taking you out of combat after a damage pause of 10 seconds.
   For some reasons, the maximum time between damages is capped at 6 seconds. 
   
   It is important to note, that comparing DPS with others is stupid in general. It is
   most useful for yourself to try new attack sequences or to compare gear and talent
   settings. If you make such comparisons, always use numbers from the same damage meter,
   because comparisons between different damage meters are meaningless.

