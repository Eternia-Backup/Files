/obj/item/weapon/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = NOBLUDGEON
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/datum/wires/explosive/plastic/wires = null
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0

/obj/item/weapon/plastique/New()
	wires = new(src)
	..()

/obj/item/weapon/plastique/suicide_act(var/mob/user)
	. = (BRUTELOSS)
	viewers(user) << "<span class='suicide'>[user] activates the C4 and holds it above his head! It looks like \he's going out with a bang!</span>"
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == "traitor" || role == "syndicate" || role == "syndicate commando")
				message_say = "FOR THE SYNDICATE!"
			else if(role == "changeling")
				message_say = "FOR THE HIVE!"
			else if(role == "cultist")
				message_say = "FOR NARSIE!"
			else if(role == "ninja")
				message_say = "FOR THE CLAN!"
			else if(role == "wizard")
				message_say = "FOR THE FEDERATION!"
			else if(role =="revolutionary" || role == "head revolutionary")
				message_say = "FOR THE REVOLOUTION!"
			else if(role == "death commando" || role == "emergency response team")
				message_say = "FOR NANOTRASEN!"

	user.say(message_say)
	target = user
	explode(get_turf(user))
	return .

/obj/item/weapon/plastique/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"
	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		wires.Interact(user)
	else
		..()

/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime > 60000)
		newtime = 60000
	timer = newtime
	user << "Timer set for [timer] seconds."


/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/) || istype(target, /obj/machinery/door/airlock/hatch/gamma))
		return
	user << "Planting explosives..."
	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		if(target:ckey)
			msg_admin_attack("[user.real_name] ([user.ckey]) tried planting [name] on [target:real_name] ([target:ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")


	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		src.target = target
		loc = null

		if (ismob(target))
			add_logs(user, target, "planted [name] on")
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted C4 on [key_name(target)](<A HREF='?_src_=holder;adminmoreinfo=\ref[target]'>?</A>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted C4 on [key_name(target)] with [timer] second fuse")

		else
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted C4 on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted C4 on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			explode(get_turf(target))

/obj/item/weapon/plastique/proc/explode(var/location)

	if(!target)
		target = get_atom_on_turf(src)
	if(!target)
		target = src
	if(location)
		explosion(location, 0, 1, 3, 6)

	if(target)
		if (istype(target, /turf/simulated/wall))
			target:dismantle_wall(1)
		else
			target.ex_act(1)
		if (isobj(target))
			if (target)
				del(target)
	del(src)

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return