ItHelp.connect_prod

locations = {
             'au60-su' => 438,
             'au60-mu'=> 438,
             'au100' => 675,
             'ba30' => 500,
             'flo6' => 440,
             'foe62' => 690,
             'frei56' => 698,
             'ge11' => 701,
             'ge13' => 702,
             'ge09' => 700,
             'ha31' => 628,
             'ha27' => 677,
             'ha39' => 665,
             'ha41' => 548,
             'he05' => 555,
             'hir20' => 696,
             'hoe3' => 682,
             'li45' => 681,
             'li47' => 628,
             'li65' => 488,
             'pfi6' => 436,
             'sq125' => 542,
             'sq131' => 540,
             'toes1' => 708,
             'wa12' => 684
            }

Item.all.each do |item|
 if item.location.nil?
   ithelp = ItHelp.find_by_inventory_code(item.inventory_code)
   unless ithelp.nil? or ithelp.building.blank?
     item.location = Location.find(locations[ithelp.building])
     puts "Assigned location #{item.location} to #{item.to_s}"
     if item.save
       puts "++ Assignment okay."
     else
       puts "-- Assignment failed for #{item.to_s}"
     end
   end
 end
end

# productive:
# 436 Pfingstweidstrasse, 6 (PF)
# 438 Ausstellungsstrasse, 60 (SQ)
# 439 
# 440 Florhofgasse, 6 (FH)
# 488 Limmatstrasse, 65 (LI)
# 491 Förrlibuckstrasse (FB)
# 499 Gessnerallee, 11 (GE)
# 500 Baslerstrasse, 30 (Mediacampus) (MC)
# 539 Tössertobelstrasse, 1 (TT)
# 540 Sihlquai, 131 (PI)
# 541 Technoparkstrasse, 1 (TP)
# 542 Sihlquai, 125 (FI)
# 548 Hafnerstrasse, 41 (DG)
# 555 Herostrasse, 5 (HA)
# 578 Hafnerstrasse, 31 (HS)
# 593 Nicht spezifizierte Adresse (ZZ)
# 622 Ge09 ()
# 628 Limmatstrasse, 47 (LH)
# 649 K17 ()
# 665 Hafnerstrasse, 39 (DI)
# 673 Andere Non-ZHDK Addresse (ZO)
# 674 Heimadresse des Benutzers (ZP)
# 675 Ausstellungsstrasse, 100 (AU)
# 676 Freiestrasse, 56 (FR)
# 677 Hafnerstrasse, 27 (HF)
# 678 Herostrasse, 10 (HB)
# 679 Hirschengraben, 46 (HI)
# 680 Limmatstrasse, 57 (KO)
# 681 Limmatstrasse, 45 (LS)
# 682 Höschgasse 3 (MB)
# 683 Seefeldstrasse, 225 (SE)
# 684 Waldmannstrasse, 12 (WA)
# 685 Flo6 ()
# 686 see225 ()
# 687 Hafnerstrasse, 39 (DI)
# 688 Militärstrasse, 47 (Z3)
# 689 Hafnerstrasse, 39 (DI)
# 690 Förrlibuckstrasse, 62 (FOE)
# 691 Hardturmstrasse, 11 (P5)
# 692 Höschgasse 4 (VE)
# 693 Baslerstrasse, 30 (MCA)
# 694 Florhofgasse, 6 (FLG)
# 695 Hirschengraben, 1 (HI1)
# 696 Hirschengraben, 20 (HI20)
# 697 Hirschengraben, 46 (HI46)
# 698 Freiestrasse, 56 (FRS)
# 699 Seefeldstrasse, 225 (SFS)
# 700 Gessnerallee, 9 (GA9)
# 701 Gessnerallee, 11 (GA11)
# 702 Gessnerallee, 13 (GA13)
# 703 Militärstrasse, 47 (Z3)
# 704 Florastrasse, 52 (FLS)
# 705 Merkurstrasse, 61 (MES)
# 706 Flurstrasse, 85 (FLU)
# 707 Albisriederstr. 184B (ARS)
# 708 Tösstobelstrasse, 1 (TOE)
# 709 Rychenberg, 82 (RY82)
# 710 Rychenberg, 94 (RY94)
# 711 Rychenberg, 96-100 (RY96)
# 712 Ifangstrasse, 2 (IFS)
# 713 Schützenmattstrsse, 1B (BU)
# 714 Kart-Stauffer-Strasse, 26 (KST)
