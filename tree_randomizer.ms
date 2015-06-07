-- manage trees en-masse in your scene
-- distribute trees along target verts

tStats = #()
sTerrain = undefined
fn select3 = select (for o in selection where classof o == foliage collect o)
select3 ()
rollout m3 "m3" width:104 height:448
(
	local targetObj = #()
	label lbl_top "manage3" pos:[32,4] width:48 height:17
	button btn_seed "seed" pos:[24,64] width:56 height:24 toolTip:"select foliage and assign random seed"
	button btn_unique "make unique" pos:[8,32] width:88 height:24 toolTip:"select trees and make them unique"
	pickbutton btn_i_src "source tree" pos:[8,104] width:88 height:24 toolTip:"select source tree"
	button btn_i_exe "connect" pos:[16,136] width:72 height:24 toolTip:"re-instance selected trees to source tree"
	button btn_height "height" pos:[24,176] width:56 height:24 toolTip:"select foliage and assign random height"
	label lbl_bottom "@101craft" pos:[26,428] width:52 height:14
	button btn_density "density" pos:[24,240] width:56 height:24 enabled:true toolTip:"select foliage and assign random density"
	button btn_rot "rotate" pos:[24,208] width:56 height:24 toolTip:"select foliage and assign random rotation"
	button btn_omega "omega" pos:[24,392] width:56 height:24 toolTip:"randomize everything with a single click"
	checkbutton btn_leaves "leaves" pos:[24,280] width:56 height:24 toolTip:"leaves on/off"
	pickbutton btn_terrain "source terrain" pos:[8,320] width:88 height:24 message:"" toolTip:"select source terrain"
	button btn_distribute "distribute" pos:[16,352] width:72 height:24 toolTip:"distribute trees along terrain"
	on btn_seed pressed do -- assign random seed
	(
	select3 ()
	for n = 1 to selection.count do selection[n].seed = random 1 1000000
	)
		
	on btn_unique pressed do -- make trees unique
	(
	select3 ()
	instancemgr.makeobjectsunique $ #individual
	)
	
	on btn_i_src picked sourceObj do -- define source tree of the new instance array
	(
	select3 ()
	btn_i_src.text = sourceObj.name
	targetObj[1] = sourceObj
	select (for o in objects where classof o == foliage collect o)
	)
	on btn_i_exe pressed do -- re-instance unique trees with source tree
	(
	select3 ()
	if targetObj[1] != undefined do for o in selection do o.baseobject = targetObj[1].baseobject
	)
	on btn_height pressed do -- assign random height
	(
	select3 ()
	if selection.count > 1 then oHeight = $[1].height
	else oHeight = $.height
	if tStats[1] == undefined do tStats[1] = oHeight
	for n = 1 to selection.count do selection[n].height = random (tStats[1] / 2.0) (tStats[1] * 1.5)
	print (tStats[1])
	)
	on btn_density pressed do -- assign random density
	(
	select3 ()
	for n = 1 to selection.count do selection[n].density = random 0.0 1.0
	)
	on btn_rot pressed do -- assign random rotation
	(
	select3 ()
	for n = 1 to selection.count do rotate selection[n] (eulerangles 0 0 (random 0 (2*n)))
	)
	on btn_omega pressed do -- alpha & omega: hit once randomize everything
	(
	select3 ()
		for n = 1 to selection.count do 
		(
		instancemgr.makeobjectsunique $ #individual
		rotate selection[n] (eulerangles 0 0 (random 0 (2*n)))
		if selection.count > 1 then oHeight = $[1].height
		else oHeight = $.height
		if tStats[1] == undefined do tStats[1] = oHeight
		selection[n].height = random (tStats[1] / 2.0) (tStats[1] * 1.5)
		selection[n].density = random 0.0 1.0
		if sTerrain != undefined do for n =1 to sTerrain.verts.count do for t = 1 to selection.count do selection[t].pos = sTerrain.verts[t].pos
		)
	)
	on btn_leaves changed state do -- leaves switch off / on, i.e. for AO rendering
	(
	select3 ()
		if state == true then 
		(
		try($.showleaves = off
		$.showflowers = off
		$.showfruit = off)catch()
		)
		else if state == false then 
		(
		try($.showleaves = on
		$.showflowers = on
		$.showfruit = on)catch()
		)
	)
	on btn_terrain picked sourceTerrain do -- pick source terrain i.e. environment geometry
	(
	if superclassof sourceTerrain == geometryclass then 
	(
		if classof sourceTerrain != editable_poly do 
		(
		resetxform sourceTerrain
		convertto sourceTerrain editable_poly
		)
	print (sourceTerrain.verts.count)
	btn_terrain.text = sourceTerrain.name
	global sTerrain = sourceTerrain
	)
	else messagebox ("select geometry")	
	)
	on btn_distribute pressed do -- distribute trees along terrain verts
	(
		local gLimit = 512
		if sTerrain.verts.count < gLimit then
		(
		select3 ()
		nTimes = sTerrain.verts.count - selection.count
		sTree = $ as array
		iTree = #()
		if nTimes > 0 do for i = 1 to nTimes do 
		(
		nTree = instance $[1]
		append iTree nTree
		)
		select (join iTree sTree)
		for n =1 to sTerrain.verts.count do for t = 1 to selection.count do selection[n].pos = sTerrain.verts[n].pos
		sTree = undefined
		iTree = undefined
		nTree = undefined
		)
		else messagebox ("geometry exceeds " +gLimit as string)
	)
)
createdialog m3