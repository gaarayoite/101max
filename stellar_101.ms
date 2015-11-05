-- parametric model of a solar system

global root = undefined
global elements = #()
global tracks = #()
global base = #()
global top = #()
global planets = #()
global rad = 0

fn pur tar =
(
	s_x = 0.0
	s_y = 0.0
	s_z = 0.0

	s_x = tar.position.x
	s_y = tar.position.y
	s_z = tar.position.z
)

fn tone arr n rnd =
(  
	for a = 1 to arr.count do 
	(
	-- mat = Arch___Design__mi()
	mat = standard()
	mat.name = "m_" + arr[a] as string
	mod = 255.0 / arr.count
	a1 = (255-a*mod as integer)
	a2 = (0+a*mod as integer)
	r = 255
	g = 255
	b = 255
	if n == 1 then (r = a1; g = a2)
		else if n == 2 then (g = a1; b = a2)
			else if n == 3 then (g = a1; b = a2)
	c = color r g b 0
	mat.diffuse = c
	arr[a].material = mat
	)
)

fn life arr dir spd =
(
	for a = 1 to arr.count do
	(
		with animate on
		(
		   at time 0 rotate arr[a] (angleAxis 0 [0, 0, 1])
		   at time 50 rotate arr[a] (angleAxis (spd * dir) [0, 0, 1])
		)
		
		ctr = getXYZControllers arr[a].rotation.controller
		for c in ctr do
		(	
			for k in c.keys do
			(
			k.inTangentType = #linear
			k.outTangentType = #linear
			)
		)
		setAfterORT arr[a].rotation.controller #relativeRepeat
	)
)

fn kill arr =
(
	for a = 1 to arr.count do delete arr[a]
)

fn origin child parent =
(
	child.parent = parent
)

fn procreate x y z size circles circle_gap orbits orbit_gap ceiling sun =
(
	root = undefined
	elements = #()
	tracks = #()
	base = #()
	top = #()
	planets = #()
	rad = 0
	-- root
	root = circle radius:(size*circles*circle_gap*1.5) pos:[x,y,z] name: "stellar_root"
	append base root
	
	-- base circles
	for c = 1 to circles do
	(
		rnd = random 0.1 3.0
		rad = rnd+size*c*circle_gap
		clone = circle radius:rad pos:[x,y,z] steps:32 name: ("stellar_base_" + c as string)
		m = sweep current_built_in_shape: 2
		addModifier clone m
		classof clone
		m[4].length = 1.5
		m[4].width = 1.5 * c
		origin clone root
		append base clone
	)
	
	-- base links
	links = random 3 6
	for l = 1 to links do
	(
		rot = (360 / links) * l
		clone = box pos:[x,y,z] rotation:(eulerangles 0 90 0) length: 1.5 width: 0.75 height: rad name: ("stellar_link_" + l as string)
		rotate clone (angleAxis rot [0, 0, 1])
		origin clone root
		append base clone
	)	
	
	-- base hemisphere
	s = sphere radius:(0.5 * sun) smooth:on segs:32 pos:[x,y,z] hemisphere:0.5 name: "stellar_base"
	origin s root
	append base s

	-- rod cylinder base
	b = cylinder pos:[x,y,z] radius:2.0 smooth:on heightsegs:1 capsegs:1 sides:16 height: ((0.5 * sun) + 0.1) name: "stellar_rod_base"
	origin b s
	append base b
	
	-- rod cylinder
	r = cylinder pos:[x,y,z] radius:(b.radius * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: ceiling name: "stellar_rod"
	origin r b
	append base r

	-- sun root
	s_r = dummy pos:[x,y,ceiling] name: ("stellar_core_root")
	origin s_r r	
	append top s_r
	
	-- sun sphere
	s = sphere radius:sun smooth:on segs:32 pos:[x,y,ceiling] name: "stellar_core"
	origin s s_r
	append top s
	
	-- rod cylinder base
	c = cylinder pos:[x,y,ceiling-(sun+0.1)] radius:(b.radius * 1.25) smooth:on heightsegs:1 capsegs:1 sides:16 height: (2*sun + 0.2) name: "stellar_rod_sun"
	origin c s
	append top c
	
	--orbits
	for o = 1 to orbits do
	(
		-- orbit roots / dummies
		d = dummy pos:[x,y,ceiling] name: ("stellar_orbit_root_" + o as string)
		origin d s_r
		append tracks d
		append top d
		rnd = random 0.5 10.0
		rim = rnd+(sun*2)+o*orbit_gap
		
		-- orbits
		orbit = circle radius:rim pos:[x,y,ceiling] steps:32 name: ("stellar_orbit_" + o as string)
		m = sweep current_built_in_shape: 4
		addModifier orbit m
		classof orbit
		m[4].radius = 1.5	
		origin orbit d
		append top orbit
		
		-- planets
		rnd = random 5.0 (sun-(sun*0.25)) 
		p = sphere radius:rnd smooth:on segs:32 pos:[rim,y,ceiling] name: ("stellar_orbit_planet_" + o as string)
		origin p orbit
		append planets p
		append top p
		
		-- orbit holders
		c = cylinder pos:[ceiling,y,z] rotation: (eulerangles 0 90 0) radius:(r.radius * 0.5) smooth:on heightsegs:1 capsegs:1 sides:16 height: (rim) name: ("stellar_orbit_holder_" + o as string)
		origin c orbit
		append top c
			
		-- animate
		rnd = random 0 1
		if rnd == 0 then dir = -1
			else if rnd == 1 then dir = 1
		life tracks dir (2 * rim as integer)
			
		-- set orbit rotation
		r1 = random -120 120
		r2 = random -30 30
		rotate d (angleAxis r1 [0, 0, 1])
		rotate d (angleAxis r2 [0, 1, 0])
		
		-- orbit orientation
		orbit.rotation.controller = Orientation_Constraint ()
		orbit.rotation.controller.appendTarget d 100
		orbit.rotation.controller.local_world = 1
		orbit.rotation.controller.relative = on	
	)
	
	c = cylinder pos:[x,y,ceiling] radius:(r.radius * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: (ceiling*0.25) name: "stellar_holder"
	origin c s
	append top c
	elements = join base top
	tone base 1 0
	tone top 2 0
	tone planets 3 (random 0 255)
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:160
(
	global sun_min = 5.0
	global sun_max = 50.0
	global sun_def = 20.0
	
	global ceiling_min = 50.0
	global ceiling_max = 1000.0
	global ceiling_def = 200.0
	
	global circles_min = 1
	global circles_max = 10
	global circles_def = 3
	
	global c_gap_min = 1.0
	global c_gap_max = 10.0
	global c_gap_def = 3.0
	
	global orbits_min = 1
	global orbits_max = 20
	global orbits_def = 5
	
	global o_gap_min = 5.0
	global o_gap_max = 75.0
	global o_gap_def = 20.0
	
	global s_x
	global s_y
	global s_z
	
	spinner spn_size "" pos:[8,8] width:48 height:16 range:[1,10,5] type:#integer toolTip:"system size"
	spinner spn_sun "" pos:[8,24] width:48 height:16 range:[5,50,20] type:#float toolTip:"sun size"
	spinner spn_ceiling "" pos:[56,24] width:48 height:16 range:[50,1000,200] type:#float toolTip:"system height"
	spinner spn_circles "" pos:[56,56] width:48 height:16 range:[1,10,3] type:#integer toolTip:"number of base circles"
	spinner spn_c_gap "" pos:[8,56] width:48 height:16 range:[1,10,3] type:#float toolTip:"gaps between circles"
	spinner spn_orbits "" pos:[56,72] width:48 height:16 range:[1,20,5] type:#integer toolTip:"number of orbits"
	spinner spn_o_gap "" pos:[8,72] width:48 height:16 range:[5,75,20] type:#float toolTip:"gaps between orbits"
	button btn_create "procreate" pos:[32,128] width:72 height:24 toolTip:"abracadabra"
	checkbutton chk_kill "annihilate" pos:[8,96] width:96 height:24 toolTip:"delete current before creating next" state:true
	button btn_c_3 "" pos:[24,128] width:8 height:24 toolTip:"create new system based on random extreme values"
	button btn_c_2 "" pos:[16,128] width:8 height:24 toolTip:"create new system based on random upper extreme values"
	button btn_c_1 "" pos:[8,128] width:8 height:24 toolTip:"create new system based on random lower extreme values"
	label lbl_101 "101craft" pos:[60,6] width:43 height:16

	on btn_create pressed do
	(
		if chk_kill.state == true do kill elements
		procreate s_x s_y s_z spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value
		select root
		purge root
	)
	on btn_c_1 pressed do
	(
		if chk_kill.state == true do kill elements
		procreate s_x s_y s_z spn_size.value (random circles_min circles_def) (random c_gap_min c_gap_def) (random orbits_min orbits_def) (random o_gap_min o_gap_def) (random ceiling_min ceiling_def) (random sun_min sun_def)
		select root
		purge root
	)
	on btn_c_2 pressed do
	(
		if chk_kill.state == true do kill elements
		procreate s_x s_y s_z spn_size.value (random circles_def circles_max) (random c_gap_def c_gap_max) (random orbits_def orbits_max) (random o_gap_def o_gap_max) (random ceiling_def ceiling_max) (random sun_def sun_max)
		select root
		purge root
	)
	on btn_c_3 pressed do
	(
		if chk_kill.state == true do kill elements
		procreate s_x s_y s_z spn_size.value (random circles_min circles_max) (random c_gap_min c_gap_max) (random orbits_min orbits_max) (random o_gap_min o_gap_max) (random ceiling_min ceiling_max) (random sun_min sun_max)
		select root
		purge root
	)
)

createdialog stellar()