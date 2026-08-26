-- +goose Up
-- Sample articles. Every outlet, byline, organisation and place name below is
-- invented; nothing here describes a real person, company or event.
--
-- Timestamps are relative to when the migration runs, so the list always looks
-- current no matter when the stack is first started.

INSERT INTO articles (id, title, summary, body, image_path, author, source, category, published_at, disabled) VALUES
    ('9b7de9fe-b477-5418-b126-2cb5b8aa56a6', 'Open-source maintainers push back on unpaid support requests', 'A growing number of volunteer maintainers are closing their issue trackers to commercial users who pay nothing for the software they depend on.', 'The maintainers of several widely used libraries have begun redirecting commercial support requests to paid channels, arguing that the current arrangement asks volunteers to underwrite the reliability of products they have no stake in.

Not everyone welcomes the shift. Smaller studios say they lack the budget for support contracts and worry that the projects they build on are drifting towards a two-tier model, where response times track spending rather than severity.',
     '/articles/technology-01.svg', 'Ada Kelsall', 'The Kestrel Review', 'technology',
     NOW() - INTERVAL '3 hours', FALSE),
    ('08b61d12-6b3f-5fe4-a946-0b58ddaba937', 'Small firms turn to on-premise hardware as cloud bills climb', 'For predictable, steady workloads, a rack in a cupboard is quietly becoming defensible again.', 'A handful of mid-sized firms have moved steady-state workloads back onto hardware they own, reporting that predictable traffic patterns made the arithmetic straightforward once egress charges were counted properly.

The move is rarely a full retreat. Most keep bursty or seasonal work on rented capacity and treat the owned hardware as a floor, which sidesteps the capacity planning problem that made on-premise unattractive in the first place.',
     '/articles/technology-02.svg', 'Joel Adeyemi', 'Signal & Cipher', 'technology',
     NOW() - INTERVAL '94 hours', FALSE),
    ('d18a4568-4e49-5b4b-8c51-ffd3ef8dbad8', 'A quiet revival for keyboard-driven interfaces', 'Command palettes have spread from developer tools to software with no technical audience at all.', 'The command palette, once confined to code editors, now appears in project trackers, design tools and customer support consoles. Its appeal is unglamorous: it removes the need to remember where a feature lives in a menu.

Designers caution that a palette is not a substitute for navigable structure. Where it has worked best, it sits alongside a coherent interface rather than papering over one that grew without a plan.',
     '/articles/technology-03.svg', 'Maren Halvorsen', 'Two Rivers Tribune', 'technology',
     NOW() - INTERVAL '185 hours', TRUE),
    ('94a26676-daba-5655-b3f0-81f57525c9c4', 'Why the humble spreadsheet still runs half the business world', 'Attempts to replace spreadsheets with purpose-built tools keep running into the same wall: nobody can predict what the next question will be.', 'Every few years a wave of software promises to retire the spreadsheet, and every few years the spreadsheet absorbs the use case instead. Its advantage is not features but latitude: a column can be added by someone with no training and no permission.

That latitude is also the risk. Auditors point out that the same flexibility which makes a spreadsheet useful makes it nearly impossible to verify, and that critical calculations often survive for years without anyone checking them.',
     '/articles/technology-04.svg', 'Tomas Brand', 'Meridian Post', 'technology',
     NOW() - INTERVAL '276 hours', FALSE),
    ('b800ac05-cce9-5573-8816-9d941a67be5e', 'Four-day week trials move from novelty to negotiation', 'What began as a recruitment experiment is increasingly turning up as a bargaining position.', 'Shorter weeks are appearing in pay negotiations rather than press releases, with unions treating reduced hours as an alternative to headline increases. Employers who trialled the arrangement report that output held once meeting culture was addressed.

Sectors with fixed coverage requirements have found it harder. Where a desk must be staffed for a set number of hours, a shorter week becomes a hiring question rather than a scheduling one.',
     '/articles/business-01.svg', 'Freya Nolan', 'The Longview', 'business',
     NOW() - INTERVAL '87 hours', FALSE),
    ('3698dc2a-2cc1-582a-9784-106e71d36ec7', 'High-street landlords rethink the twenty-year lease', 'Shorter terms and turnover-linked rents are becoming the price of keeping units occupied.', 'Long commercial leases are giving way to shorter agreements with break clauses, as landlords weigh reduced certainty against the cost of an empty unit. Turnover-linked rents, once rare outside shopping centres, are spreading to secondary streets.

Tenants are cautious about the trade. A rent that moves with revenue lowers the risk of a bad year, but it also requires opening the books to a landlord, and small operators are wary of what that visibility invites.',
     '/articles/business-02.svg', 'Oscar Vidal', 'Fathom Weekly', 'business',
     NOW() - INTERVAL '178 hours', FALSE),
    ('e74698c3-faa2-5f45-ae93-f7e6091c5b48', 'The return of the repair shop', 'Right-to-repair rules have created demand that the trade does not yet have the people to meet.', 'Independent repair businesses report enquiry volumes they cannot service, with waits of several weeks for common appliance work. The constraint is not parts, which have become easier to obtain, but qualified hands.

Training providers say the pipeline was dismantled over two decades and will not be rebuilt in one. Several have restarted apprenticeships, though the first cohorts will not be productive for years.',
     '/articles/business-03.svg', 'Nia Okafor', 'Northwind Daily', 'business',
     NOW() - INTERVAL '269 hours', FALSE),
    ('d78829e3-cf46-5fa0-8a3d-7ca7e32c377f', 'Freight operators bet on smaller, more frequent loads', 'Warehouse economics are shifting towards flow rather than bulk.', 'Operators are running smaller consignments more often, trading the efficiency of a full trailer for lower holding costs and faster response to demand. The change is most visible in regional distribution, where routes are short enough to absorb the extra trips.

Critics note the environmental arithmetic is not obviously favourable. More frequent journeys mean more vehicle movements, and the saving depends on whether the alternative was a full load or a half-empty one.',
     '/articles/business-04.svg', 'Sam Oyelaran', 'Harbour Report', 'business',
     NOW() - INTERVAL '80 hours', FALSE),
    ('a3e16356-cdcd-57be-a295-91fc5ddeba92', 'Lower-league clubs find a lifeline in fan ownership', 'Supporter trusts are taking on more of the balance sheet, and more of the difficult decisions with it.', 'Several lower-league clubs have moved to supporter ownership after periods of financial distress, with trusts raising capital through member subscriptions rather than seeking a single backer.

The model brings its own strains. Boards drawn from the terraces must make unpopular calls about wage budgets and ticket prices, and the absence of a wealthy owner removes the option of covering a shortfall with someone else''s money.',
     '/articles/sport-01.svg', 'Ruth Ellery', 'The Kestrel Review', 'sport',
     NOW() - INTERVAL '171 hours', FALSE),
    ('0fa66552-d88e-58ae-a479-7c8c23613fe0', 'Distance runners are training slower to race faster', 'Coaches are pulling easy mileage further below race pace, and the results are showing up in the second half of races.', 'Training plans across distance running have shifted towards a wider gap between easy and hard sessions, with recovery runs slower than many club athletes find comfortable to admit to.

The rationale is durability rather than speed. Coaches report fewer interrupted blocks, and argue that consistency across a season matters more than the quality of any individual week.',
     '/articles/sport-02.svg', 'Rowan Petrie', 'Signal & Cipher', 'sport',
     NOW() - INTERVAL '262 hours', TRUE),
    ('7b6742c3-0e26-5b1a-ae9c-3ce290621e29', 'The scouting notebook survives the analytics era', 'Data has narrowed the search, not replaced the eye.', 'Recruitment departments now use models to shortlist, then send scouts to answer the questions the data cannot: how a player responds to a bad first touch, whether they organise the people around them.

The division of labour has proved durable. Clubs that leaned entirely on either method report expensive mistakes, and most now treat disagreement between the two as a signal worth investigating rather than a problem to resolve.',
     '/articles/sport-03.svg', 'Hana Ito', 'Two Rivers Tribune', 'sport',
     NOW() - INTERVAL '73 hours', FALSE),
    ('0961360d-fb8e-5a91-b887-f69ef9e7ff2f', 'Velodrome revival draws a new generation of track riders', 'Cheap taster sessions are filling tracks that spent a decade underused.', 'Track sessions aimed at complete beginners have filled velodromes that struggled for bookings, with several venues reporting waiting lists for introductory classes.

Clubs are now short of coaches rather than riders. The qualification takes months, and the volunteers who ran the sport through leaner years are, by their own account, tired.',
     '/articles/sport-04.svg', 'Kofi Mensah', 'Meridian Post', 'sport',
     NOW() - INTERVAL '164 hours', FALSE),
    ('8b4ee998-4ebf-5a09-95f4-2172cf2628ee', 'Engineered timber moves from curiosity to construction site', 'Mid-rise buildings in engineered wood are getting past planning, and past insurers.', 'Engineered timber has moved from demonstration projects to ordinary mid-rise construction, helped by fire testing that satisfied insurers who had previously declined to quote.

Supply remains the constraint. The panels require specific species and processing capacity that exists in a handful of places, and architects report lead times long enough to shape the design itself.',
     '/articles/science-01.svg', 'Isla Mackenzie', 'The Longview', 'science',
     NOW() - INTERVAL '255 hours', FALSE),
    ('1de9ffa6-503e-5736-8aa9-c3dc8bee5ff2', 'Deep-sea mapping turns up more questions than answers', 'Higher-resolution surveys keep finding structures that existing models did not predict.', 'New survey passes over previously mapped seabed are returning features fine enough to contradict earlier interpretations, including sediment patterns that suggest currents behaving differently than modelled.

Researchers are careful about how much weight to put on this. Better resolution reveals detail that was always there, and distinguishing a genuine surprise from an artefact of the instrument takes years.',
     '/articles/science-02.svg', 'Callum Reith', 'Fathom Weekly', 'science',
     NOW() - INTERVAL '66 hours', FALSE),
    ('4960406f-95d2-5467-800a-2f65cc91fe4e', 'Citizen scientists are rewriting the record on urban birdsong', 'Thousands of amateur recordings have produced a dataset no research budget could have funded.', 'Volunteer recordings gathered across dozens of towns have built a picture of urban birdsong at a density professional surveys could not afford, revealing variation between neighbourhoods a few streets apart.

Validating the data has been the hard part. Recordings vary in quality and volunteers cluster where they live, so the coverage is uneven in ways that must be corrected before any conclusion holds.',
     '/articles/science-03.svg', 'Lena Draper', 'Northwind Daily', 'science',
     NOW() - INTERVAL '157 hours', FALSE),
    ('4103e222-f588-52d3-85ff-aa260005cbf8', 'The unglamorous work of replicating famous results', 'Replication projects are slow, poorly funded, and increasingly regarded as essential.', 'Several groups have taken on the deliberate replication of well-known findings, a task that attracts little funding and less citation, on the grounds that the alternative is a literature nobody can rely on.

The results have been mixed rather than damning. Many findings hold with smaller effects than first reported, which researchers describe as the expected outcome of publishing incentives rather than evidence of bad faith.',
     '/articles/science-04.svg', 'Dev Raman', 'Harbour Report', 'science',
     NOW() - INTERVAL '248 hours', FALSE),
    ('7bc4b406-2857-51c4-8bda-3bc5462ff619', 'Walking prescriptions gain ground with reluctant patients', 'Referrals to organised walking groups are reaching people who would not join a gym.', 'Clinics referring patients to organised walking groups report better attendance than for conventional exercise programmes, with the social element cited more often than the physical one.

The groups depend on volunteer leaders, and capacity varies sharply by area. Practices in districts without an established group have little to refer patients to.',
     '/articles/health-01.svg', 'Priya Bhatt', 'The Kestrel Review', 'health',
     NOW() - INTERVAL '59 hours', FALSE),
    ('a202cfe5-da8d-562a-ad3d-1e13b6524882', 'Sleep clinics report a surge in referrals from shift workers', 'Services designed around a nine-to-five day are struggling to assess people who do not have one.', 'Sleep services are seeing more referrals from shift workers, a group whose difficulties are poorly captured by assessments built around a conventional day.

Clinicians say the useful interventions are often organisational rather than medical: predictable rota patterns and adequate gaps between shifts do more than anything they can prescribe.',
     '/articles/health-02.svg', 'Yusuf Kaya', 'Signal & Cipher', 'health',
     NOW() - INTERVAL '150 hours', FALSE),
    ('1828dde3-211b-5252-9af1-ffec2683a5a9', 'Community pharmacies take on more of the front line', 'Expanded prescribing powers have shortened some queues and lengthened others.', 'Pharmacies handling minor conditions directly have reduced pressure on general practice for a defined list of complaints, with patients reporting shorter waits.

Pharmacy bodies warn the work has arrived faster than the funding. Several report absorbing consultations into hours designed for dispensing, with no additional staff.',
     '/articles/health-03.svg', 'Marta Lindqvist', 'Two Rivers Tribune', 'health',
     NOW() - INTERVAL '241 hours', FALSE),
    ('bb26ca01-8f04-58c1-a0d8-a10076383d20', 'Why hospital design is finally paying attention to noise', 'Sound levels on wards routinely exceed the thresholds that recovery guidance recommends.', 'Measurements on inpatient wards regularly exceed recommended night-time levels, driven less by equipment than by conversation, doors and flooring.

Retrofitting is awkward. Acoustic treatment competes with infection control requirements for wipeable surfaces, and the cheapest interventions turn out to be procedural rather than structural.',
     '/articles/health-04.svg', 'Elias Voss', 'Meridian Post', 'health',
     NOW() - INTERVAL '52 hours', FALSE),
    ('ae8efc7f-df3b-5267-b4a5-2e2a256e572b', 'Independent cinemas bet on repertory over new releases', 'Older films, programmed well, are outselling first-run screenings at several venues.', 'Independent cinemas leaning on repertory programming report stronger attendance than for new releases, where they compete on terms set by distributors.

The approach demands work that a release schedule does not. Curating a season, securing rights to older prints and building an audience for them is a skill venues are having to relearn.',
     '/articles/entertainment-01.svg', 'Ada Kelsall', 'The Longview', 'entertainment',
     NOW() - INTERVAL '143 hours', FALSE),
    ('73bdec94-b207-55f0-ad97-17dc670848ab', 'The audio drama is having its second golden age', 'Production costs low enough for a small team have produced a wave of ambitious serials.', 'Audio drama has expanded well beyond its public-radio origins, with independent teams producing serialised fiction at budgets that would not cover a single day of filming.

Discovery is the bottleneck. Listeners find shows through recommendation rather than search, and producers describe marketing as the largest line item after sound design.',
     '/articles/entertainment-02.svg', 'Joel Adeyemi', 'Fathom Weekly', 'entertainment',
     NOW() - INTERVAL '234 hours', FALSE),
    ('7844d22a-3eed-580d-847e-8fc9e4bbc920', 'Touring musicians split the difference on ticket pricing', 'Tiered pricing is spreading as artists try to protect cheap seats without absorbing the cost themselves.', 'More tours are pricing seats in bands rather than uniformly, using higher prices at the front to hold down the cheapest tickets.

Audiences have been ambivalent. The cheap tickets are genuinely cheaper, but the practice makes visible a hierarchy that a single price concealed.',
     '/articles/entertainment-03.svg', 'Maren Halvorsen', 'Northwind Daily', 'entertainment',
     NOW() - INTERVAL '45 hours', FALSE),
    ('94178c8e-4efb-571b-bb6d-cd7e44f4429a', 'Board game cafes outlast the boom that created them', 'The survivors turned out to be the ones selling coffee rather than games.', 'Board game cafes that weathered the sector''s contraction tend to be those that treated the games as a reason to stay rather than the thing being sold.

Margins remain thin. A table occupied for three hours by two people generates little, and most venues now run events, leagues or membership schemes to fill quiet weekdays.',
     '/articles/entertainment-04.svg', 'Tomas Brand', 'Harbour Report', 'entertainment',
     NOW() - INTERVAL '136 hours', FALSE),
    ('a3d70aaf-528d-56e3-aa2f-3a4ee4f07ca5', 'Local councils experiment with participatory budgets', 'Handing a slice of spending to residents produces different priorities than officers expect.', 'Councils putting portions of discretionary spending to a resident vote report allocations that differ from officer recommendations, with maintenance consistently favoured over new projects.

The sums involved are small. Critics call the exercise a distraction from decisions taken elsewhere; supporters argue that participation has to start somewhere it cannot do much harm.',
     '/articles/politics-01.svg', 'Freya Nolan', 'The Kestrel Review', 'politics',
     NOW() - INTERVAL '227 hours', TRUE),
    ('29510ff5-ca64-51b9-8c92-219a1afb5af8', 'Postal voting reforms face a quiet second reading', 'Administrative changes with significant practical effects are moving with little debate.', 'Proposed changes to postal voting administration are progressing with limited attention, despite altering deadlines that election officials say determine whether late applications can be processed at all.

Returning officers have asked for clarity on timing above all else. Their submissions focus less on the policy than on whether the schedule leaves enough working days to deliver it.',
     '/articles/politics-02.svg', 'Oscar Vidal', 'Signal & Cipher', 'politics',
     NOW() - INTERVAL '38 hours', FALSE),
    ('c77b4857-5af9-5355-9762-259f79dd5756', 'Select committee calls for clearer procurement rules', 'Evidence sessions found the same problems recurring across unrelated departments.', 'A committee reviewing procurement practice has recommended simpler rules after hearing that current guidance is interpreted inconsistently even within single departments.

Officials pushed back on the diagnosis. Their evidence attributed variation to capability and turnover rather than to the rules, and warned that simplification could remove safeguards that exist for reasons no longer remembered.',
     '/articles/politics-03.svg', 'Nia Okafor', 'Two Rivers Tribune', 'politics',
     NOW() - INTERVAL '129 hours', FALSE),
    ('604dc96d-fc86-5565-bb68-dce1fd6de5cc', 'Devolved transport powers put to their first real test', 'A contested route decision is the first case where the new arrangements bind.', 'A disputed route decision has become the first substantial test of devolved transport powers, with responsibility for the outcome now clearly local rather than shared.

Both sides have found the clarity uncomfortable. Local leaders can no longer defer upwards, and central government can no longer intervene without unpicking the settlement it created.',
     '/articles/politics-04.svg', 'Sam Oyelaran', 'Meridian Post', 'politics',
     NOW() - INTERVAL '220 hours', FALSE),
    ('b93c20d1-8ef0-5860-be2b-34d430102d9e', 'Night trains return to timetables across the continent', 'Sleeper services are being restored, though rarely on the routes campaigners asked for.', 'Overnight rail services have reappeared on several long routes after two decades of withdrawal, driven by demand for alternatives to short-haul flights.

Rolling stock is the limiting factor. Sleeper carriages are expensive and slow to build, and operators are running refurbished vehicles while new orders sit years out.',
     '/articles/travel-01.svg', 'Ruth Ellery', 'The Longview', 'travel',
     NOW() - INTERVAL '31 hours', FALSE),
    ('2dcb4926-871c-527b-9ba6-35817eda553b', 'Coastal paths struggle under their own popularity', 'Erosion is outpacing maintenance on the best-known sections.', 'Popular coastal routes are showing wear that maintenance budgets cannot keep up with, with widened desire lines and surface loss concentrated on a small number of sections.

Managers are reluctant to promote alternatives, since publicity is what created the problem. Several are instead improving access to quieter stretches without naming them in campaigns.',
     '/articles/travel-02.svg', 'Rowan Petrie', 'Fathom Weekly', 'travel',
     NOW() - INTERVAL '122 hours', FALSE),
    ('590e32bc-ca09-5f33-a52a-d7be1dfdc240', 'Slow ferries find an unexpected audience', 'Journeys sold on their duration rather than in spite of it are filling berths.', 'Ferry operators marketing long crossings as time rather than delay report strong bookings, particularly on routes where the alternative is a short flight and two airport transfers.

The economics are marginal. Fuel and crewing costs scale with hours at sea, and operators concede the proposition works only where the schedule suits the traveller anyway.',
     '/articles/travel-03.svg', 'Hana Ito', 'Northwind Daily', 'travel',
     NOW() - INTERVAL '213 hours', FALSE),
    ('1190ef5b-213a-56dc-a5b8-3d61c4582422', 'Small airports pivot to freight and flight schools', 'Regional fields that lost scheduled passengers are finding other tenants.', 'Regional airports without scheduled passenger services are converting capacity to freight handling, maintenance and training, all of which use runways at times passengers would not.

Local opposition has followed the change. Training flights generate more movements than departures ever did, and residents who accepted a quiet airport are less accommodating of a busy one.',
     '/articles/travel-04.svg', 'Kofi Mensah', 'Harbour Report', 'travel',
     NOW() - INTERVAL '24 hours', FALSE),
    ('124dff1b-be0f-58a9-907c-f07446ffd206', 'Regional grain revival puts old wheat back on menus', 'Bakers are paying more for varieties that mills spent decades phasing out.', 'Small mills are processing older wheat varieties again at the request of bakers, who report flavour differences significant enough to justify the higher price and the inconsistency.

Yields are the obstacle. The varieties produce less per acre than modern equivalents, so the supply depends on growers willing to accept a premium price for a smaller harvest.',
     '/articles/food-01.svg', 'Isla Mackenzie', 'The Kestrel Review', 'food',
     NOW() - INTERVAL '115 hours', FALSE),
    ('ab195ad9-3c8a-5135-a636-e90e0aaa7eee', 'Restaurants trim menus to survive rising ingredient costs', 'Shorter menus reduce waste, and expose any weak dish immediately.', 'Kitchens are cutting menus substantially, reporting lower waste and simpler ordering. Several describe the discipline as overdue rather than forced.

Diners notice the constraint. Regulars object when a familiar dish disappears, and operators say the hardest part is deciding which loyalty to disappoint.',
     '/articles/food-02.svg', 'Callum Reith', 'Signal & Cipher', 'food',
     NOW() - INTERVAL '206 hours', FALSE),
    ('9ef7d3a2-8b3e-5274-9fbf-c425849f70c2', 'Community kitchens become the new village hall', 'Shared cooking spaces are taking on functions that closed venues used to hold.', 'Shared kitchens set up to address food costs have become general-purpose community spaces, hosting classes, meetings and clubs that lost their previous venues.

Funding follows the original purpose, not the current one. Organisers report writing applications about nutrition for spaces whose main value has become somewhere to be.',
     '/articles/food-03.svg', 'Lena Draper', 'Two Rivers Tribune', 'food',
     NOW() - INTERVAL '17 hours', FALSE),
    ('08175267-cdab-52ef-9b03-998104b95dfe', 'The unfashionable vegetable making a comeback', 'Growers report demand for a crop that supermarkets stopped listing years ago.', 'Growers are planting varieties that disappeared from supermarket ranges, driven by demand from restaurants and box schemes rather than retailers.

Scale remains small and the market narrow. Growers are candid that a single restaurant closing can remove a meaningful share of a season''s orders.',
     '/articles/food-04.svg', 'Dev Raman', 'Meridian Post', 'food',
     NOW() - INTERVAL '108 hours', TRUE),
    ('ce3df83e-244a-5e1d-84c8-bece4f54eaf3', 'River monitoring volunteers outnumber official inspectors', 'Amateur sampling has become the main source of data on many smaller waterways.', 'Volunteer groups now carry out the majority of routine sampling on many smaller rivers, producing records at a frequency official monitoring does not attempt.

The status of the data is contested. Regulators accept it as an indicator rather than evidence, which volunteers find frustrating given that no other record exists.',
     '/articles/environment-01.svg', 'Priya Bhatt', 'The Longview', 'environment',
     NOW() - INTERVAL '199 hours', FALSE),
    ('17e1f871-5c9e-510f-a919-cbcf8d054929', 'Retrofitting terraces proves harder than building new', 'Every house is slightly different, and that is the whole problem.', 'Retrofit programmes on terraced housing are running behind schedule, with surveyors reporting that near-identical houses turn out to differ in ways that invalidate a standard specification.

Installers say the work resists industrialisation for that reason. Each property needs an assessment, and the assessment often costs a meaningful fraction of the work itself.',
     '/articles/environment-02.svg', 'Yusuf Kaya', 'Fathom Weekly', 'environment',
     NOW() - INTERVAL '10 hours', FALSE),
    ('256f7011-b49d-5e9c-887a-cee3cb9a32d5', 'Urban tree planting shifts focus from count to survival', 'Planting targets are being replaced by targets for trees still alive after five years.', 'Councils are moving from planting numbers to survival rates after audits found substantial losses within a few years, mostly attributed to inadequate watering in the first two summers.

The change makes aftercare the expensive part. Watering a young tree through a dry spell requires someone to do it repeatedly, which is harder to fund than a planting day.',
     '/articles/environment-03.svg', 'Marta Lindqvist', 'Northwind Daily', 'environment',
     NOW() - INTERVAL '101 hours', FALSE),
    ('75e1d8b9-8a35-543f-a2df-d1757697142f', 'Peatland restoration measured in decades, not seasons', 'The work is quick; the recovery is not.', 'Peatland restoration schemes are reporting early hydrological improvements while cautioning that carbon outcomes will not be measurable for decades.

That timescale complicates funding. Grant cycles run to a few years, and restoration bodies describe repackaging continuous work as a series of discrete projects to fit them.',
     '/articles/environment-04.svg', 'Elias Voss', 'Harbour Report', 'environment',
     NOW() - INTERVAL '192 hours', FALSE);

-- +goose Down
DELETE FROM articles WHERE id IN (
    '9b7de9fe-b477-5418-b126-2cb5b8aa56a6',
    '08b61d12-6b3f-5fe4-a946-0b58ddaba937',
    'd18a4568-4e49-5b4b-8c51-ffd3ef8dbad8',
    '94a26676-daba-5655-b3f0-81f57525c9c4',
    'b800ac05-cce9-5573-8816-9d941a67be5e',
    '3698dc2a-2cc1-582a-9784-106e71d36ec7',
    'e74698c3-faa2-5f45-ae93-f7e6091c5b48',
    'd78829e3-cf46-5fa0-8a3d-7ca7e32c377f',
    'a3e16356-cdcd-57be-a295-91fc5ddeba92',
    '0fa66552-d88e-58ae-a479-7c8c23613fe0',
    '7b6742c3-0e26-5b1a-ae9c-3ce290621e29',
    '0961360d-fb8e-5a91-b887-f69ef9e7ff2f',
    '8b4ee998-4ebf-5a09-95f4-2172cf2628ee',
    '1de9ffa6-503e-5736-8aa9-c3dc8bee5ff2',
    '4960406f-95d2-5467-800a-2f65cc91fe4e',
    '4103e222-f588-52d3-85ff-aa260005cbf8',
    '7bc4b406-2857-51c4-8bda-3bc5462ff619',
    'a202cfe5-da8d-562a-ad3d-1e13b6524882',
    '1828dde3-211b-5252-9af1-ffec2683a5a9',
    'bb26ca01-8f04-58c1-a0d8-a10076383d20',
    'ae8efc7f-df3b-5267-b4a5-2e2a256e572b',
    '73bdec94-b207-55f0-ad97-17dc670848ab',
    '7844d22a-3eed-580d-847e-8fc9e4bbc920',
    '94178c8e-4efb-571b-bb6d-cd7e44f4429a',
    'a3d70aaf-528d-56e3-aa2f-3a4ee4f07ca5',
    '29510ff5-ca64-51b9-8c92-219a1afb5af8',
    'c77b4857-5af9-5355-9762-259f79dd5756',
    '604dc96d-fc86-5565-bb68-dce1fd6de5cc',
    'b93c20d1-8ef0-5860-be2b-34d430102d9e',
    '2dcb4926-871c-527b-9ba6-35817eda553b',
    '590e32bc-ca09-5f33-a52a-d7be1dfdc240',
    '1190ef5b-213a-56dc-a5b8-3d61c4582422',
    '124dff1b-be0f-58a9-907c-f07446ffd206',
    'ab195ad9-3c8a-5135-a636-e90e0aaa7eee',
    '9ef7d3a2-8b3e-5274-9fbf-c425849f70c2',
    '08175267-cdab-52ef-9b03-998104b95dfe',
    'ce3df83e-244a-5e1d-84c8-bece4f54eaf3',
    '17e1f871-5c9e-510f-a919-cbcf8d054929',
    '256f7011-b49d-5e9c-887a-cee3cb9a32d5',
    '75e1d8b9-8a35-543f-a2df-d1757697142f'
);
