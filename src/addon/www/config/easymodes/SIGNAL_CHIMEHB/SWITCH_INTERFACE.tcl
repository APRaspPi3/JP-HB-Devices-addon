#!/bin/tclsh

source [file join $env(DOCUMENT_ROOT) config/easymodes/em_common.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/EnterFreeValue.tcl]
source [file join $env(DOCUMENT_ROOT) config/easymodes/etc/options.tcl]

set PROFILES_MAP(0)	"\${expert}"
set PROFILES_MAP(1)	"\${signal_led_chime_active}"
set PROFILES_MAP(2) "\${signal_led_chime_non_active}"

set PROFILE_0(UI_HINT)	0
set PROFILE_0(UI_DESCRIPTION)		"Expertenprofil"
set PROFILE_0(UI_TEMPLATE)			"Expertenprofil"

set PROFILE_1(SHORT_CT_OFFDELAY)	0
set PROFILE_1(SHORT_CT_ONDELAY)		0
set PROFILE_1(SHORT_CT_OFF)			0
set PROFILE_1(SHORT_CT_ON)			0
set PROFILE_1(SHORT_COND_VALUE_LO)	50 
set PROFILE_1(SHORT_COND_VALUE_HI)	100
set PROFILE_1(SHORT_ONDELAY_TIME)	0
set PROFILE_1(SHORT_ON_TIME)		{111600 6}
set PROFILE_1(SHORT_OFFDELAY_TIME)	0
set PROFILE_1(SHORT_OFF_TIME)		111600
set PROFILE_1(SHORT_ON_TIME_MODE)	0
set PROFILE_1(SHORT_OFF_TIME_MODE)	0
set PROFILE_1(SHORT_ACTION_TYPE)	1
set PROFILE_1(SHORT_JT_OFF)			1
set PROFILE_1(SHORT_JT_ON)			0
set PROFILE_1(SHORT_JT_OFFDELAY)	0
set PROFILE_1(SHORT_JT_ONDELAY)		0 
set PROFILE_1(SHORT_ACT_TYPE)		0
set PROFILE_1(SHORT_ACT_NUM)		1
set PROFILE_1(SHORT_ACT_INTENS)		0
set PROFILE_1(UI_DESCRIPTION)	"Bei Bet&auml;tigung des Schaltkontaktes wird der Gong entsprechend des gew&auml;hlten Schaltmodus geschaltet."
set PROFILE_1(UI_TEMPLATE)		$PROFILE_1(UI_DESCRIPTION)	
set PROFILE_1(UI_HINT)	1

set PROFILE_2(SHORT_ACTION_TYPE)	0
set PROFILE_2(UI_DESCRIPTION)		"Das Schaltinterface ist deaktiviert."
set PROFILE_2(UI_TEMPLATE)		$PROFILE_2(UI_DESCRIPTION)	
set PROFILE_2(UI_HINT) 2

#set SUBSET_1(NAME)					"Ein / Aus"
set SUBSET_1(NAME)					"\${subset_1}"
set SUBSET_1(SUBSET_OPTION_VALUE)	1
set SUBSET_1(SHORT_JT_OFF)			1
set SUBSET_1(SHORT_JT_ON)			3
set SUBSET_1(SHORT_JT_OFFDELAY)		4
set SUBSET_1(SHORT_JT_ONDELAY)		2 

#set SUBSET_2(NAME)					"Ein"
set SUBSET_2(NAME)					"\${subset_2}"
set SUBSET_2(SUBSET_OPTION_VALUE)	2
set SUBSET_2(SHORT_JT_OFF)			1
set SUBSET_2(SHORT_JT_OFFDELAY)		0
set SUBSET_2(SHORT_JT_ON)			0
set SUBSET_2(SHORT_JT_ONDELAY)		0


proc set_htmlParams {iface address pps pps_descr special_input_id peer_type} {
	
	global env receiver_address dev_descr_sender dev_descr_receiver
	upvar PROFILES_MAP  PROFILES_MAP
	upvar HTML_PARAMS   HTML_PARAMS
	upvar PROFILE_PNAME PROFILE_PNAME
	upvar $pps          ps      
	upvar $pps_descr    ps_descr
	
	foreach pro [array names PROFILES_MAP] {
		upvar PROFILE_$pro PROFILE_$pro
	}
 		
	set cur_profile [get_cur_profile2 ps PROFILES_MAP PROFILE_TMP $peer_type]
	
	#global SUBSETS
	set name "x"
	set i 1
	while {$name != ""} {
		upvar SUBSET_$i SUBSET_$i
		array set subset [array get SUBSET_$i]
		set name ""
		catch {set name $subset(NAME)}
		array_clear subset
		incr i
	}

#	die Texte der Platzhalter einlesen
	puts "<script type=\"text/javascript\">getLangInfo('$dev_descr_sender(TYPE)', '$dev_descr_receiver(TYPE)HB');</script>"
	set prn 0	
	append HTML_PARAMS(separate_$prn) "<div id=\"param_$prn\"><textarea id=\"profile_$prn\" style=\"display:none\">"
	append HTML_PARAMS(separate_$prn) [cmd_link_paramset2 $iface $address ps_descr ps "LINK" ${special_input_id}_$prn]
	append HTML_PARAMS(separate_$prn) "</textarea></div>"
#1
	incr prn
	set pref 1
	if {$cur_profile == $prn} then {array set PROFILE_$prn [array get ps]}
	append HTML_PARAMS(separate_$prn) "<div id=\"param_$prn\"><textarea id=\"profile_$prn\" style=\"display:none\">"
	append HTML_PARAMS(separate_$prn) "\${description_$prn}"
	append HTML_PARAMS(separate_$prn) "<table class=\"ProfileTbl\">"

	append HTML_PARAMS(separate_$prn) "<tr><td>\${SWITCH_MODE}</td><td>"
	append HTML_PARAMS(separate_$prn) [subset2combobox {SUBSET_1 SUBSET_2} subset_$prn\_$pref separate_${special_input_id}_$prn\_$pref PROFILE_$prn ]
	append HTML_PARAMS(separate_$prn) "</td></tr>"

	incr pref ;# 2
	append HTML_PARAMS(separate_$prn) "<tr><td>\${OFFDELAY_TIME}</td><td>"
	option DELAY
	append HTML_PARAMS(separate_$prn) [get_ComboBox options SHORT_OFFDELAY_TIME|LONG_OFFDELAY_TIME separate_${special_input_id}_$prn\_$pref PROFILE_$prn SHORT_OFFDELAY_TIME "onchange=\"ActivateFreeTime(\$('${special_input_id}_profiles'),$pref);\""]
	EnterTime_h_m_s $prn $pref ${special_input_id} ps_descr SHORT_OFFDELAY_TIME
	append HTML_PARAMS(separate_$prn) "</td></tr>"

	# Signalart
	source [file join $env(DOCUMENT_ROOT) config/easymodes/SIGNAL_CHIMEHB/signal_type.tcl]

	append HTML_PARAMS(separate_$prn) "</table></textarea></div>"
#2
	incr prn 
	if {$cur_profile == $prn} then {array set PROFILE_$prn [array get ps]}
	append HTML_PARAMS(separate_$prn) "<div id=\"param_$prn\"><textarea id=\"profile_$prn\" style=\"display:none\">"
	append HTML_PARAMS(separate_$prn) "\${description_$prn}"
	append HTML_PARAMS(separate_$prn) "</textarea></div>"
}

constructor
