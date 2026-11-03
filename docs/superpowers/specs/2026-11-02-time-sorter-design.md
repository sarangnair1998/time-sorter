# Time Sorter: Design

Game jam: GitHub Game Off 2026, theme **Shift**. Engine: Godot 4 (4.7.2 installed), 3D, GDScript. Web (HTML5) export for itch.io.
Jam window: Nov 1 to Dec 1, 2026. Submit on itch.io and push to the public GitHub repo before **Dec 1, 13:37 PST**. Target: submitted by **Nov 29**.

## 1. What the game is

You are an extra-dimensional creature who sorts time. Each shift, you take over a human body in a room that looks out on a real historical event. Nothing in the room states the date. Combine the clues, then mark the exact day on the modern Gregorian calendar. Reach the required score or you're fired.

"Shift" works twice: a work shift, and shifting through time.

The jam build is **two rooms**: a tutorial room, then one polished main room.

## 2. Goals, non-goals, anti-goals

**Goals**
- A complete, playable run in the browser: intro, tutorial room, main room, score, fired or pass.
- The deduction is the fun. Clues are subtle, human and in-world, in the manner of Return of the Obra Dinn.
- The theme is readable inside the game, not only on the itch page.
- Real sound and music. Audio is a rating category.

**Non-goals (for the jam)**
- More than two rooms.
- Calendar-system puzzles (Julian, lunisolar, regnal years, Hijri and so on).
- A free-walking character controller, anywhere. The intro is a camera-on-rails cutscene with free look, so none is needed.
- A mirror.

**Anti-goals** (failure even if it technically works)
- A clue states the date of the event.
- Clues that are tricks rather than honestly findable.
- Violent or graphic events.
- Scope that keeps growing and puts the submission at risk.

## 3. The player's experience, in order

1. **Title screen.** Obra Dinn / Inscryption look, a few lines of text, Start and Options.
2. **Intro cutscene** (Should, see section 8). The camera moves along a fixed path automatically, and the player can look around at any time. The hallway walk is on rails, up to the workstation room. From there the player is in control, moving between spots as in every other room.
   - You open a door and walk in. The boss, at his desk, looks you up and down.
   - A dark text card in the Obra Dinn manner: "You're late for your first shift." then "Not that it means anything here."
   - "Let me take you to the workstation." You follow him slowly along a hallway to a door with a device that lets you jump into timelines. He says the process is called **shiftleak**.
   - In the workstation room the boss stands by the unsorted pile on the left. You pick up a Time-Orb and carry it to him, and he sets it in the machine. He says "I'll guide you through the process", and the tutorial begins inside that world.
   - The author writes the script.
3. **Tutorial room** (section 5). The boss, also the guide, sits with you.
4. **Back to the workstation.** On lock-in the score appears and the boss says a line on a text card. You return to the workstation, fetch the next Time-Orb the same way, and he places it in the machine. The jump itself dissolves into the dither pattern as the next room forms.
5. **Main room** (section 6). No guide.
6. **Result.** Pass: the shift ends. Fail: the boss comes in and fires you, in the author's words, and you retry the same room. Same answer key, and the 10-question budget resets. (Builder's call.)

## 4. Systems

**Camera and movement**
- First person, in the Inscryption manner.
- Fixed viewpoints (`Marker3D` nodes). Clicking a spot glides the camera there with a `Tween`.
- At every spot the player can look around freely, including down at their own body (hands, sleeves, clothes). Looking at yourself is free camera look, not a spot.
- Looking at the player's body needs a simple low-poly body with drawn clothing textures.

**Workstation room.** A reusable environment, built once. It uses the same spots and clicks as every other room: a spot at the unsorted pile, a spot at the machine, a spot by the boss. Click an orb to pick it up (it attaches to your view), then click the machine slot at the machine spot to place it. This is the routine between levels. In the jam it runs once in the intro and once between the tutorial and the main room, and again after being fired.

**Interaction.** Raycast from the camera to click and inspect props. Inspecting adds items and words to the notebook.

**Observation window**
- A normal window that fits the room's era. Clicking it moves the camera to the glass.
- A hand-drawn 2D animation of 20 to 30 seconds plays once per click: the event, the surroundings, the atmosphere and the reactions together.
- Unlimited replays.
- Drawn by the author in the game's art style.

**Question tool**
- Click two things from the notebook or room, then a question type: **when, where, why, who**. The game forms the question and shows the answer.
- A useful answer uses one of **10** questions per room. "Nothing useful" is free. The 10 is a total across all question types. When it runs out, the player must guess. (Builder's call.)
- "When" gives a **range** that narrows as clues combine, never the exact day.
- If it proves too easy in playtests, tighten it (a limit on free attempts, for example).
- Answers are authored per pair and question type. Only meaningful pairs get an answer (roughly 15 to 25 per room); every other pair returns "nothing useful". Each authored answer is a fixed text with a fixed range, stored in a data file. The range does not narrow by computation; the player narrows it by combining the ranges from several answers, which the notebook records. (Builder's call: a lookup table, not a rules engine.)

**Guess and score**
- The player marks a day on a Gregorian calendar and locks it in.
- Score uses a logarithmic curve: exact day scores most, falling quickly over days, then months, then years, then levelling out.
- Each room has a required score. Numbers to be set during playtesting.

**Handbook.** A short employee handbook with corporate time-bureaucracy humour. For the jam, a few pages that unlock as the player progresses. Text to be written.

**The guide.** A hand-drawn 2D sprite that always faces the camera (a billboard `Sprite3D`). Speech appears as a bubble above their head in the room. The boss and the guide are the same character. Tutorial dialogue is a linear script plus a small table of one-line reactions to specific props. (Builder's call.)

## 5. Tutorial room

**Event:** FIFA World Cup final, **Sunday, July 19, 2026**, MetLife Stadium, East Rutherford, New Jersey. Spain beat Argentina 1-0 after extra time (to be verified against a primary source). The room has no location of its own; the window shows the event.

**Answer key:** July 19, 2026.

**The person:** Dani, a hospital porter on rotating shifts, who shares a flat with a flatmate who backs the other side. (The name is a placeholder.)

**Teaches:** clicking props, the notebook, the question tool, marking a guess on the calendar. The tutorial cannot be failed: it always passes, and the boss comments on the score. (Builder's call.)

**Clues**

No clue names the event, a team, or the date. Each describes what you would see. The window is the main way to recognise the event; the room confirms it. See Appendix A for the full list. Prop families:
- The event: newspaper back page, notebook, bin stub, TV, window animation.
- Teams: red shirt, blue and white scarf and throw, mugs, fridge note, flags.
- Weekday and time: wall clock, phone, sticky note, rota.
- Counting: postcard, receipt, planner.
- Season, year and place: sunscreen and fan, poster, calendar, transit pass.
- Personality: the flatmate, the split sofa, the rota, the lanyard.

## 6. Main room

**Event:** the Leonid meteor storm, North America, the night of **November 12 to 13, 1833**.

**Answer key:** **November 13, 1833**, the day of the peak (to be verified). A guess of November 12 still scores almost full marks through the curve.

**The person:** a country schoolteacher with a hobby in stargazing, who is not a professional astronomer. The room mixes school things (slate, copybooks, letters) with a small telescope and star charts, so it is not only sky clues.

**Clues:** the builder drafts the clue list and the answer table by the end of week 2, and the author approves them. Same rules as section 5. Mix at least four of these: sky, dated documents, first appearances, day of the week, season and nature, money and prices, sound, language.

**Calendar:** Gregorian only for this room. No conversion puzzle.

## 7. Look and sound

- **Look:** Obra Dinn and Inscryption. Drawn by the author. Low-poly 3D props with 2D drawings as textures for letters, newspapers, posters, coins and the handbook.
- **Dither and grain shader** over the whole screen. Added last.
- **Sound and music:** to be decided. Real time is reserved in the schedule.
- **Web export:** tested early and often. Builder's calls:
  - Use the Compatibility renderer from the start, and write the dither shader to work in it.
  - Play each window animation as a video (Ogg Theora), made from the author's frames at 8 to 12 fps and about 640 by 360.
  - Keep each animation under about 15 MB and the whole web build under about 60 MB.

## 8. Scope control

**Must** (the game does not ship without these)
- Workstation room, tutorial room, main room, and the orb fetch and jump between them.
- Camera spots with free look, click-to-inspect, notebook.
- Observation window animation for each room.
- Question tool, calendar guess, scoring, fired and retry.
- Title screen, web export, public repo, itch.io page.
- Music and sound.

**Should** (cut in this order if time runs short)
1. Intro cutscene on rails with free look. Fallback: a short fixed-camera intro with the same text cards.
2. Handbook pages.
3. Extra clue props beyond a core set.
4. Look-down body model. Fallback: a drawn view of hands and sleeves.
5. Dither shader polish.

**Parked** (needs an explicit yes and something of equal size removed)
- Mirror
- Calendar-system rooms
- More rooms
- Anything new

**Rules**
- This spec is frozen once approved. A new idea goes in Parked.
- Adding to Must or Should means removing something of equal size.
- If a week ends behind schedule, cut from the Should list. Do not extend the Must list.

## 9. Schedule

| Week | Dates | Goal |
|------|-------|------|
| 1 | Nov 2 to 8 | Spec, plan, Godot project, grey-box tutorial room with camera spots, clicking, notebook. First web export test. |
| 2 | Nov 9 to 15 | Question tool, calendar guess, scoring, workstation room and orb fetch, the jump. Tutorial room playable end to end. |
| 3 | Nov 16 to 22 | Main room built and playable. Window animations drawn. |
| 4 | Nov 23 to 29 | Intro, handbook, music, sound, dither shader, playtests, bug fixes. Submit by Nov 29. |

Drawing the window animations and music run in parallel from week 2.

## 10. Tracking

- Bugs and tasks live in **GitHub Issues** with labels: `bug`, `feature`, `art`, `audio`, `content`, `polish`, `web-export`, `blocker`, `playtest`.
- One milestone per week.
- Commit small and often. Keep the repo public from the start.

## 11. Open questions

- The name of the game.
- Intro script and pictures (author writes).
- Score numbers and the pass score.
- Exact palette and shader details.
- Music and sound direction.
- Handbook text.
- The author's drawing tool for the window animations. Recommendation: any tool that exports a PNG frame sequence or a video file; the builder converts it. Test with a 3-second sample in week 1.
- Approval of the main-room clue list and answer table (drafted by the end of week 2).

## Appendix A: Tutorial room clues (current draft)

| Prop | What the player sees |
|------|----------------------|
| Newspaper | A back page of tables: rows of three-letter codes and numbers, a tiny flag beside each. Tomorrow's weather: hot, storms later. |
| Notebook | Doodles of a bowl-shaped building, a list of food and drink amounts, and "ask T. about the big screen". |
| Grocery list | Ice, crisps, drinks (lots), paper plates. Two days circled, a third underlined twice. |
| Bin | A crumpled card stub: GATE C, ROW 12, SEAT 7. Everything else has worn away. |
| Calendar | A July page. The numbers are rubbed off and one square has been pressed hard with a pen. |
| Shirt | A red shirt, hung up to dry. |
| Observation window | A packed ground, two sides in different colours, a roar. |
| Wall clock | Stopped at ten past four. |
| Poster | A faded poster with three flags (a maple leaf, stars and stripes, a green, white and red band). The year is peeling: "20_6". |
| Wall planner | Two months, almost all crossed off. One box left, with a star. |
| Postcard | Postmark smudged: "JU_ 28". "Three weeks to go! I'll save you a seat." |
| Receipt | Pizza, 9:41 pm. The date reads 17/07 but the fold hides the year. |
| Phone | Lock screen: 4:12, battery 9%. One notification: "Starting soon". |
| Sticky note | "Mon off. Do NOT ring me before noon." |
| Sunscreen and fan | A tube of sunscreen, a handheld fan, a damp towel. |
| Scarf | Blue and white stripes, tied to the chair. |
| Transit pass | A monthly pass, printed to the 31st. |
| TV | On, volume low: a man talking over crowd noise. |
| Fridge | Two sets of leftovers on separate shelves, each labelled in different handwriting. |
| Fridge note | "Loser cooks dinner." Two tiny flags underneath, one red and one blue. |
| Rota | A rota grid, mostly filled in. One day says "SWAP?" with a name beside it. Monday is blank. |
| Lanyard | A hospital lanyard: PORTER, and a first name, "Dani". The photo has a sunburnt nose. |
| Sofa | Split down the middle by a wall of cushions. A blue and white throw on one side, a red hoodie on the other. |
| Mugs | Two mugs: one red, one blue and white. Both empty, both stained. |

To verify before the art is drawn: the tournament schedule (semi-final and third-place days), the kick-off time, and whether the time of day suits the window animation.

## Appendix B: Intended deduction chain for the tutorial room (draft, for the author's approval)

The author approves this before any "when" ranges or answers are written.

1. **Recognise the event.** The window shows a packed ground and two sides in different colours. The newspaper tables, the TV crowd noise and the notebook doodles point to football. The poster's three flags and the year "20_6" point to a 2026 tournament in North America.
2. **Find the teams.** The red shirt and the blue and white scarf suggest two national sides. The question tool ("who" on the shirt and the scarf) answers with the two teams. The fridge note and the split sofa show that it is a contest between two people.
3. **Find the stage.** The planner has one box left, marked with a star, which is the last day of the tournament. The player works out that it is the final.
4. **Place it in the week.** "Mon off, do NOT ring me before noon" suggests the big day is the day before a Monday, so a Sunday. The rota shows Monday blank.
5. **Place it in the calendar.** The postcard, postmarked "JU_ 28", says three weeks to go, which gives mid-July. The receipt reads 17/07, two days before. The year is 2026 from the poster. The Sunday after 17 July 2026 is July 19.
6. **Check.** July 17, 2026 was a Friday, and the receipt is for a Friday-night pizza.

The "when" ranges should agree with this chain at each step, so the player can follow it.
