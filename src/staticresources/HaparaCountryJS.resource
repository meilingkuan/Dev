/*
	*	Original script by: Shafiul Azam
	*	ishafiul@gmail.com
	*	Version 3.0
	*	Modified by: Luigi Balzano

	*	Description:
	*	Inserts Countries and/or States as Dropdown List
	*	How to Use:

		In Head section:
		<script type= "text/javascript" src = "countries.js"></script>
		In Body Section:
		Select Country:   <select onchange="print_state("state",this.selectedIndex);" id="country" name ="country"></select>
		<br />
		City/District/State: <select name ="state" id ="state"></select>
		<script language="javascript">print_country("country");</script>	

	*
	*	License: OpenSource, Permission for modificatin Granted, KEEP AUTHOR INFORMATION INTACT
	*	Aurthor"s Website: http://shafiul.progmaatic.com
	*
*/
	
var Afghanistan = "Afghanistan";	var intAfghanistan = 1;
var Albania = "Albania";	var intAlbania = 2;
var Algeria = "Algeria";	var intAlgeria = 3;
var American_Samoa = "American Samoa";	var intAmerican_Samoa = 4;
var Andorra = "Andorra";	var intAndorra = 5;
var Angola = "Angola";	var intAngola = 6;
var Anguilla = "Anguilla";	var intAnguilla = 7;
var Antarctica = "Antarctica";	var intAntarctica = 8;
var Antigua_and_Barbuda = "Antigua and Barbuda";	var intAntigua_and_Barbuda = 9;
var Argentina = "Argentina";	var intArgentina = 10;
var Armenia = "Armenia";	var intArmenia = 11;
var Aruba = "Aruba";	var intAruba = 12;
var Australia = "Australia";	var intAustralia = 13;
var Austria = "Austria";	var intAustria = 14;
var Azerbaijan = "Azerbaijan";	var intAzerbaijan = 15;
var Bahamas = "Bahamas";	var intBahamas = 16;
var Bahrain = "Bahrain";	var intBahrain = 17;
var Bangladesh = "Bangladesh";	var intBangladesh = 18;
var Barbados = "Barbados";	var intBarbados = 19;
var Belarus = "Belarus";	var intBelarus = 20;
var Belgium = "Belgium";	var intBelgium = 21;
var Belize = "Belize";	var intBelize = 22;
var Benin = "Benin";	var intBenin = 23;
var Bermuda = "Bermuda";	var intBermuda = 24;
var Bhutan = "Bhutan";	var intBhutan = 25;
var Bolivia = "Bolivia";	var intBolivia = 26;
var Bonaire = "Bonaire";	var intBonaire = 27;
var Bosnia_and_Herzegovina = "Bosnia and Herzegovina";	var intBosnia_and_Herzegovina = 28;
var Botswana = "Botswana";	var intBotswana = 29;
var Bouvet_Island = "Bouvet Island";	var intBouvet_Island = 30;
var Brazil = "Brazil";	var intBrazil = 31;
var British_Indian_Ocean_Territory = "British Indian Ocean Territory";	var intBritish_Indian_Ocean_Territory = 32;
var Brunei_Darussalam = "Brunei Darussalam";	var intBrunei_Darussalam = 33;
var Bulgaria = "Bulgaria";	var intBulgaria = 34;
var Burkina_Faso = "Burkina Faso";	var intBurkina_Faso = 35;
var Burundi = "Burundi";	var intBurundi = 36;
var Cambodia = "Cambodia";	var intCambodia = 37;
var Cameroon = "Cameroon";	var intCameroon = 38;
var Canada = "Canada";	var intCanada = 39;
var Cape_Verde = "Cape Verde";	var intCape_Verde = 40;
var Cayman_Islands = "Cayman Islands";	var intCayman_Islands = 41;
var Central_African_Republic = "Central African Republic";	var intCentral_African_Republic = 42;
var Chad = "Chad";	var intChad = 43;
var Chile = "Chile";	var intChile = 44;
var China = "China";	var intChina = 45;
var Christmas_Island = "Christmas Island";	var intChristmas_Island = 46;
var Cocos__keeling__Islands = "Cocos (keeling) Islands";	var intCocos__keeling__Islands = 47;
var Colombia = "Colombia";	var intColombia = 48;
var Comoros = "Comoros";	var intComoros = 49;
var Congo = "Congo";	var intCongo = 50;
var Congo__The_Democratic_Republic_of_The = "Congo  The Democratic Republic of The";	var intCongo__The_Democratic_Republic_of_The = 51;
var Cook_Islands = "Cook Islands";	var intCook_Islands = 52;
var Costa_Rica = "Costa Rica";	var intCosta_Rica = 53;
var Croatia = "Croatia";	var intCroatia = 54;
var Cuba = "Cuba";	var intCuba = 55;
var Curacao = "Curaçao";	var intCuracao = 56;
var Cyprus = "Cyprus";	var intCyprus = 57;
var Czech_Republic = "Czech Republic";	var intCzech_Republic = 58;
var Cote_Divoire = "Côte D'ivoire";	var intCote_Divoire = 59;
var Denmark = "Denmark";	var intDenmark = 60;
var Djibouti = "Djibouti";	var intDjibouti = 61;
var Dominica = "Dominica";	var intDominica = 62;
var Dominican_Republic = "Dominican Republic";	var intDominican_Republic = 63;
var Ecuador = "Ecuador";	var intEcuador = 64;
var Egypt = "Egypt";	var intEgypt = 65;
var El_Salvador = "El Salvador";	var intEl_Salvador = 66;
var Equatorial_Guinea = "Equatorial Guinea";	var intEquatorial_Guinea = 67;
var Eritrea = "Eritrea";	var intEritrea = 68;
var Estonia = "Estonia";	var intEstonia = 69;
var Ethiopia = "Ethiopia";	var intEthiopia = 70;
var Falkland_Islands__malvinas_ = "Falkland Islands (malvinas)";	var intFalkland_Islands__malvinas_ = 71;
var Faroe_Islands = "Faroe Islands";	var intFaroe_Islands = 72;
var Fiji = "Fiji";	var intFiji = 73;
var Finland = "Finland";	var intFinland = 74;
var France = "France";	var intFrance = 75;
var French_Guiana = "French Guiana";	var intFrench_Guiana = 76;
var French_Polynesia = "French Polynesia";	var intFrench_Polynesia = 77;
var French_Southern_Territories = "French Southern Territories";	var intFrench_Southern_Territories = 78;
var Gabon = "Gabon";	var intGabon = 79;
var Gambia = "Gambia";	var intGambia = 80;
var Georgia = "Georgia";	var intGeorgia = 81;
var Germany = "Germany";	var intGermany = 82;
var Ghana = "Ghana";	var intGhana = 83;
var Gibraltar = "Gibraltar";	var intGibraltar = 84;
var Greece = "Greece";	var intGreece = 85;
var Greenland = "Greenland";	var intGreenland = 86;
var Grenada = "Grenada";	var intGrenada = 87;
var Guadeloupe = "Guadeloupe";	var intGuadeloupe = 88;
var Guam = "Guam";	var intGuam = 89;
var Guatemala = "Guatemala";	var intGuatemala = 90;
var Guernsey = "Guernsey";	var intGuernsey = 91;
var Guinea = "Guinea";	var intGuinea = 92;
var Guinea_bissau = "Guinea-bissau";	var intGuinea_bissau = 93;
var Guyana = "Guyana";	var intGuyana = 94;
var Haiti = "Haiti";	var intHaiti = 95;
var Heard_Island_and_Mcdonald_Islands = "Heard Island and Mcdonald Islands";	var intHeard_Island_and_Mcdonald_Islands = 96;
var Holy_See__vatican_City_State_ = "Holy See (vatican City State)";	var intHoly_See__vatican_City_State_ = 97;
var Honduras = "Honduras";	var intHonduras = 98;
var Hong_Kong = "Hong Kong";	var intHong_Kong = 99;
var Hungary = "Hungary";	var intHungary = 100;
var Iceland = "Iceland";	var intIceland = 101;
var India = "India";	var intIndia = 102;
var Indonesia = "Indonesia";	var intIndonesia = 103;
var Iran__Islamic_Republic_of = "Iran  Islamic Republic of";	var intIran__Islamic_Republic_of = 104;
var Iraq = "Iraq";	var intIraq = 105;
var Ireland = "Ireland";	var intIreland = 106;
var Isle_of_Man = "Isle of Man";	var intIsle_of_Man = 107;
var Israel = "Israel";	var intIsrael = 108;
var Italy = "Italy";	var intItaly = 109;
var Jamaica = "Jamaica";	var intJamaica = 110;
var Japan = "Japan";	var intJapan = 111;
var Jersey = "Jersey";	var intJersey = 112;
var Jordan = "Jordan";	var intJordan = 113;
var Kazakhstan = "Kazakhstan";	var intKazakhstan = 114;
var Kenya = "Kenya";	var intKenya = 115;
var Kiribati = "Kiribati";	var intKiribati = 116;
var Korea__Democratic_Peoples_Republic_of = "Korea  Democratic People's Republic of";	var intKorea__Democratic_Peoples_Republic_of = 117;
var Korea__Republic_of = "Korea  Republic of";	var intKorea__Republic_of = 118;
var Kuwait = "Kuwait";	var intKuwait = 119;
var Kyrgyzstan = "Kyrgyzstan";	var intKyrgyzstan = 120;
var Lao_Peoples_Democratic_Republic = "Lao People's Democratic Republic";	var intLao_Peoples_Democratic_Republic = 121;
var Latvia = "Latvia";	var intLatvia = 122;
var Lebanon = "Lebanon";	var intLebanon = 123;
var Lesotho = "Lesotho";	var intLesotho = 124;
var Liberia = "Liberia";	var intLiberia = 125;
var Libya = "Libya";	var intLibya = 126;
var Liechtenstein = "Liechtenstein";	var intLiechtenstein = 127;
var Lithuania = "Lithuania";	var intLithuania = 128;
var Luxembourg = "Luxembourg";	var intLuxembourg = 129;
var Macao = "Macao";	var intMacao = 130;
var Macedonia__The_Former_Yugoslav_Republic_of = "Macedonia  The Former Yugoslav Republic of";	var intMacedonia__The_Former_Yugoslav_Republic_of = 131;
var Madagascar = "Madagascar";	var intMadagascar = 132;
var Malawi = "Malawi";	var intMalawi = 133;
var Malaysia = "Malaysia";	var intMalaysia = 134;
var Maldives = "Maldives";	var intMaldives = 135;
var Mali = "Mali";	var intMali = 136;
var Malta = "Malta";	var intMalta = 137;
var Marshall_Islands = "Marshall Islands";	var intMarshall_Islands = 138;
var Martinique = "Martinique";	var intMartinique = 139;
var Mauritania = "Mauritania";	var intMauritania = 140;
var Mauritius = "Mauritius";	var intMauritius = 141;
var Mayotte = "Mayotte";	var intMayotte = 142;
var Mexico = "Mexico";	var intMexico = 143;
var Micronesia__Federated_States_of = "Micronesia  Federated States of";	var intMicronesia__Federated_States_of = 144;
var Moldova__Republic_of = "Moldova  Republic of";	var intMoldova__Republic_of = 145;
var Monaco = "Monaco";	var intMonaco = 146;
var Mongolia = "Mongolia";	var intMongolia = 147;
var Montenegro = "Montenegro";	var intMontenegro = 148;
var Montserrat = "Montserrat";	var intMontserrat = 149;
var Morocco = "Morocco";	var intMorocco = 150;
var Mozambique = "Mozambique";	var intMozambique = 151;
var Myanmar = "Myanmar";	var intMyanmar = 152;
var Namibia = "Namibia";	var intNamibia = 153;
var Nauru = "Nauru";	var intNauru = 154;
var Nepal = "Nepal";	var intNepal = 155;
var Netherlands = "Netherlands";	var intNetherlands = 156;
var Netherlands_Antilles = "Netherlands Antilles";	var intNetherlands_Antilles = 157;
var New_Caledonia = "New Caledonia";	var intNew_Caledonia = 158;
var New_Zealand = "New Zealand";	var intNew_Zealand = 159;
var Nicaragua = "Nicaragua";	var intNicaragua = 160;
var Niger = "Niger";	var intNiger = 161;
var Nigeria = "Nigeria";	var intNigeria = 162;
var Niue = "Niue";	var intNiue = 163;
var Norfolk_Island = "Norfolk Island";	var intNorfolk_Island = 164;
var Northern_Mariana_Islands = "Northern Mariana Islands";	var intNorthern_Mariana_Islands = 165;
var Norway = "Norway";	var intNorway = 166;
var Oman = "Oman";	var intOman = 167;
var Pakistan = "Pakistan";	var intPakistan = 168;
var Palau = "Palau";	var intPalau = 169;
var Palestinian_Territory__Occupied = "Palestinian Territory  Occupied";	var intPalestinian_Territory__Occupied = 170;
var Panama = "Panama";	var intPanama = 171;
var Papua_New_Guinea = "Papua New Guinea";	var intPapua_New_Guinea = 172;
var Paraguay = "Paraguay";	var intParaguay = 173;
var Peru = "Peru";	var intPeru = 174;
var Philippines = "Philippines";	var intPhilippines = 175;
var Pitcairn = "Pitcairn";	var intPitcairn = 176;
var Poland = "Poland";	var intPoland = 177;
var Portugal = "Portugal";	var intPortugal = 178;
var Puerto_Rico = "Puerto Rico";	var intPuerto_Rico = 179;
var Qatar = "Qatar";	var intQatar = 180;
var Romania = "Romania";	var intRomania = 181;
var Russian_Federation = "Russian Federation";	var intRussian_Federation = 182;
var Rwanda = "Rwanda";	var intRwanda = 183;
var Reunion = "Réunion";	var intReunion = 184;
var Saint_Barthelemy = "Saint Barthélemy";	var intSaint_Barthelemy = 185;
var Saint_Helena = "Saint Helena";	var intSaint_Helena = 186;
var Saint_Kitts_and_Nevis = "Saint Kitts and Nevis";	var intSaint_Kitts_and_Nevis = 187;
var Saint_Lucia = "Saint Lucia";	var intSaint_Lucia = 188;
var Saint_Martin__French_Part_ = "Saint Martin (French Part)";	var intSaint_Martin__French_Part_ = 189;
var Saint_Pierre_and_Miquelon = "Saint Pierre and Miquelon";	var intSaint_Pierre_and_Miquelon = 190;
var Saint_Vincent_and_The_Grenadines = "Saint Vincent and The Grenadines";	var intSaint_Vincent_and_The_Grenadines = 191;
var Samoa = "Samoa";	var intSamoa = 192;
var San_Marino = "San Marino";	var intSan_Marino = 193;
var Sao_Tome_and_Principe = "Sao Tome and Principe";	var intSao_Tome_and_Principe = 194;
var Saudi_Arabia = "Saudi Arabia";	var intSaudi_Arabia = 195;
var Senegal = "Senegal";	var intSenegal = 196;
var Serbia = "Serbia";	var intSerbia = 197;
var Seychelles = "Seychelles";	var intSeychelles = 198;
var Sierra_Leone = "Sierra Leone";	var intSierra_Leone = 199;
var Singapore = "Singapore";	var intSingapore = 200;
var Sint_Maartin__Dutch_Part_ = "Sint Maartin (Dutch Part)";	var intSint_Maartin__Dutch_Part_ = 201;
var Slovakia = "Slovakia";	var intSlovakia = 202;
var Slovenia = "Slovenia";	var intSlovenia = 203;
var Solomon_Islands = "Solomon Islands";	var intSolomon_Islands = 204;
var Somalia = "Somalia";	var intSomalia = 205;
var South_Africa = "South Africa";	var intSouth_Africa = 206;
var South_Georgia_and_The_South_Sandwich_Islands = "South Georgia and The South Sandwich Islands";	var intSouth_Georgia_and_The_South_Sandwich_Islands = 207;
var South_Sudan = "South Sudan";	var intSouth_Sudan = 208;
var Spain = "Spain";	var intSpain = 209;
var Sri_Lanka = "Sri Lanka";	var intSri_Lanka = 210;
var Sudan = "Sudan";	var intSudan = 211;
var Suriname = "Suriname";	var intSuriname = 212;
var Svalbard_and_Jan_Mayen = "Svalbard and Jan Mayen";	var intSvalbard_and_Jan_Mayen = 213;
var Swaziland = "Swaziland";	var intSwaziland = 214;
var Sweden = "Sweden";	var intSweden = 215;
var Switzerland = "Switzerland";	var intSwitzerland = 216;
var Syrian_Arab_Republic = "Syrian Arab Republic";	var intSyrian_Arab_Republic = 217;
var Taiwan__Province_of_China = "Taiwan  Province of China";	var intTaiwan__Province_of_China = 218;
var Tajikistan = "Tajikistan";	var intTajikistan = 219;
var Tanzania__United_Republic_of = "Tanzania  United Republic of";	var intTanzania__United_Republic_of = 220;
var Thailand = "Thailand";	var intThailand = 221;
var Timor_Leste = "Timor-Leste";	var intTimor_Leste = 222;
var Togo = "Togo";	var intTogo = 223;
var Tokelau = "Tokelau";	var intTokelau = 224;
var Tonga = "Tonga";	var intTonga = 225;
var Trinidad_and_Tobago = "Trinidad and Tobago";	var intTrinidad_and_Tobago = 226;
var Tunisia = "Tunisia";	var intTunisia = 227;
var Turkey = "Turkey";	var intTurkey = 228;
var Turkmenistan = "Turkmenistan";	var intTurkmenistan = 229;
var Turks_and_Caicos_Islands = "Turks and Caicos Islands";	var intTurks_and_Caicos_Islands = 230;
var Tuvalu = "Tuvalu";	var intTuvalu = 231;
var Uganda = "Uganda";	var intUganda = 232;
var Ukraine = "Ukraine";	var intUkraine = 233;
var United_Arab_Emirates = "United Arab Emirates";	var intUnited_Arab_Emirates = 234;
var United_Kingdom = "United Kingdom";	var intUnited_Kingdom = 235;
var United_States = "United States";	var intUnited_States = 236;
var United_States_Minor_Outlying_Islands = "United States Minor Outlying Islands";	var intUnited_States_Minor_Outlying_Islands = 237;
var Uruguay = "Uruguay";	var intUruguay = 238;
var Uzbekistan = "Uzbekistan";	var intUzbekistan = 239;
var Vanuatu = "Vanuatu";	var intVanuatu = 240;
var Venezuela__Bolivarian_Republic_of = "Venezuela  Bolivarian Republic of";	var intVenezuela__Bolivarian_Republic_of = 241;
var Viet_Nam = "Viet Nam";	var intViet_Nam = 242;
var Virgin_Islands__British = "Virgin Islands  British";	var intVirgin_Islands__British = 243;
var Virgin_Islands__U_S_ = "Virgin Islands  U.S.";	var intVirgin_Islands__U_S_ = 244;
var Wallis_and_Futuna = "Wallis and Futuna";	var intWallis_and_Futuna = 245;
var Western_Sahara = "Western Sahara";	var intWestern_Sahara = 246;
var Yemen = "Yemen";	var intYemen = 247;
var Zambia = "Zambia";	var intZambia = 248;
var Zimbabwe = "Zimbabwe";	var intZimbabwe = 249;
var None = "--None--"

var country_arr = new Array(United_States,Canada,United_Kingdom, Australia,New_Zealand, Afghanistan, Albania, Algeria, American_Samoa, Andorra, Angola, Anguilla, Antarctica, Antigua_and_Barbuda, Argentina, Armenia, Aruba, Austria, Azerbaijan, Bahamas, Bahrain, Bangladesh, Barbados, Belarus, Belgium, Belize, Benin, Bermuda, Bhutan, Bolivia,Bonaire, Bosnia_and_Herzegovina, Botswana,Bouvet_Island, Brazil, British_Indian_Ocean_Territory, Brunei_Darussalam, Bulgaria, Burkina_Faso,Burundi,  Cambodia, Cameroon,  Cape_Verde, Cayman_Islands, Central_African_Republic, Chad, Chile, China, Christmas_Island, Cocos__keeling__Islands, Colombia, Comoros, Congo, Congo__The_Democratic_Republic_of_The, Cook_Islands, Costa_Rica,  Croatia, Cuba,Curacao, Cyprus, Czech_Republic,Cote_Divoire, Denmark, Djibouti, Dominica, Dominican_Republic, Ecuador, Egypt, El_Salvador, Equatorial_Guinea, Eritrea, Estonia, Ethiopia, Falkland_Islands__malvinas_, Faroe_Islands, Fiji, Finland, France, French_Guiana, French_Polynesia, French_Southern_Territories, Gabon, Gambia, Georgia, Germany, Ghana, Gibraltar, Greece, Greenland, Grenada, Guadeloupe, Guam, Guatemala, Guernsey, Guinea, Guinea_bissau, Guyana, Haiti, Heard_Island_and_Mcdonald_Islands, Holy_See__vatican_City_State_, Honduras, Hong_Kong, Hungary, Iceland, India, Indonesia, Iran__Islamic_Republic_of, Iraq, Ireland, Isle_of_Man, Israel, Italy, Jamaica, Japan,  Jersey, Jordan,Kazakhstan, Kenya, Kiribati, Korea__Democratic_Peoples_Republic_of, Korea__Republic_of, Kuwait, Kyrgyzstan,Lao_Peoples_Democratic_Republic, Latvia, Lebanon, Lesotho, Liberia, Libya, Liechtenstein, Lithuania, Luxembourg, Macao, Macedonia__The_Former_Yugoslav_Republic_of, Madagascar, Malawi, Malaysia, Maldives, Mali, Malta, Marshall_Islands, Martinique, Mauritania, Mauritius, Mayotte, Mexico, Micronesia__Federated_States_of, Moldova__Republic_of, Monaco, Mongolia,Montenegro, Montserrat, Morocco, Mozambique,Myanmar, Namibia, Nauru, Nepal, Netherlands, Netherlands_Antilles, New_Caledonia,  Nicaragua, Niger, Nigeria, Niue, Norfolk_Island, Northern_Mariana_Islands, Norway, Oman, Pakistan, Palau,Palestinian_Territory__Occupied, Panama, Papua_New_Guinea, Paraguay, Peru, Philippines, Pitcairn, Poland, Portugal, Puerto_Rico, Qatar, Romania,Russian_Federation, Rwanda, Reunion,Saint_Barthelemy,Saint_Helena, Saint_Kitts_and_Nevis, Saint_Lucia,Saint_Martin__French_Part_, Saint_Pierre_and_Miquelon, Saint_Vincent_and_The_Grenadines, Samoa, San_Marino, Sao_Tome_and_Principe, Saudi_Arabia, Senegal,Serbia, Seychelles, Sierra_Leone, Singapore, Sint_Maartin__Dutch_Part_,Slovakia, Slovenia, Solomon_Islands, Somalia, South_Africa, South_Georgia_and_The_South_Sandwich_Islands,South_Sudan, Spain,  Sri_Lanka, Sudan, Suriname, Svalbard_and_Jan_Mayen, Swaziland, Sweden, Switzerland, Syrian_Arab_Republic, Taiwan__Province_of_China, Tajikistan, Tanzania__United_Republic_of, Thailand,Timor_Leste,Togo, Tokelau, Tonga, Trinidad_and_Tobago, Tunisia, Turkey, Turkmenistan,Turks_and_Caicos_Islands, Tuvalu, Uganda, Ukraine, United_Arab_Emirates,  United_States_Minor_Outlying_Islands,Uruguay, Uzbekistan, Vanuatu, Venezuela__Bolivarian_Republic_of, Viet_Nam, Virgin_Islands__British, Virgin_Islands__U_S_,Wallis_and_Futuna, Western_Sahara, Yemen, Zambia, Zimbabwe);

var s_a = new Array();
s_a[None]="";
//Afghanistan
s_a[Afghanistan]="Badakhshan|Badghis|Baghlan|Balkh|Bamian|Farah|Faryab|Ghazni|Ghowr|Helmand|Herat|Jowzjan|Kabol|Kandahar|Kapisa|Konar|Kondoz|Laghman|Lowgar|Nangarhar|Nimruz|Oruzgan|Paktia|Paktika|Parvan|Samangan|Sar-e Pol|Takhar|Vardak|Zabol";
//Albania
s_a[Albania]="Berat|Bulqize|Delvine|Devoll (Bilisht)|Diber (Peshkopi)|Durres|Elbasan|Fier|Gjirokaster|Gramsh|Has (Krume)|Kavaje|Kolonje (Erseke)|Korce|Kruje|Kucove|Kukes|Kurbin|Lezhe|Librazhd|Lushnje|Malesi e Madhe (Koplik)|Mallakaster (Ballsh)|Mat (Burrel)|Mirdite (Rreshen)|Peqin|Permet|Pogradec|Puke|Sarande|Shkoder|Skrapar (Corovode)|Tepelene|Tirane (Tirana)|Tirane (Tirana)|Tropoje (Bajram Curri)|Vlore";
//Algeria
s_a[Algeria]="Adrar|Ain Defla|Ain Temouchent|Alger|Annaba|Batna|Bechar|Bejaia|Biskra|Blida|Bordj Bou Arreridj|Bouira|Boumerdes|Chlef|Constantine|Djelfa|El Bayadh|El Oued|El Tarf|Ghardaia|Guelma|Illizi|Jijel|Khenchela|Laghouat|M'Sila|Mascara|Medea|Mila|Mostaganem|Naama|Oran|Ouargla|Oum el Bouaghi|Relizane|Saida|Setif|Sidi Bel Abbes|Skikda|Souk Ahras|Tamanghasset|Tebessa|Tiaret|Tindouf|Tipaza|Tissemsilt|Tizi Ouzou|Tlemcen";
//American Samoa
s_a[American_Samoa]="Eastern|Manu'a|Rose Island|Swains Island|Western";
//Andorra
s_a[Andorra]="Andorra";
//Angola
s_a[Angola]="Andorra la Vella|Bengo|Benguela|Bie|Cabinda|Canillo|Cuando Cubango|Cuanza Norte|Cuanza Sul|Cunene|Encamp|Escaldes-Engordany|Huambo|Huila|La Massana|Luanda|Lunda Norte|Lunda Sul|Malanje|Moxico|Namibe|Ordino|Sant Julia de Loria|Uige|Zaire";
//Anguilla
s_a[Anguilla]="Anguilla";
//Antartica
s_a[Antarctica]="Antartica";
//Antigua and Barbuda
s_a[Antigua_and_Barbuda]="Barbuda|Redonda|Saint George|Saint John|Saint Mary|Saint Paul|Saint Peter|Saint Philip";
//Argentina
s_a[Argentina]="Antartica e Islas del Atlantico Sur|Buenos Aires|Buenos Aires Capital Federal|Catamarca|Chaco|Chubut|Cordoba|Corrientes|Entre Rios|Formosa|Jujuy|La Pampa|La Rioja|Mendoza|Misiones|Neuquen|Rio Negro|Salta|San Juan|San Luis|Santa Cruz|Santa Fe|Santiago del Estero|Tierra del Fuego|Tucuman";
//Armenia
s_a[Armenia]="Aragatsotn|Ararat|Armavir|Geghark'unik'|Kotayk'|Lorri|Shirak|Syunik'|Tavush|Vayots' Dzor|Yerevan";
//Aruba
s_a[Aruba]="Aruba";
//Australia
s_a[Australia]="Australian Capital Territory|New South Wales|Northern Territory|Queensland|South Australia|Tasmania|Victoria|Western Australia";
//Austria
s_a[Austria]="Burgenland|Kaernten|Niederoesterreich|Oberoesterreich|Salzburg|Steiermark|Tirol|Vorarlberg|Wien";
//Azerbaijan
s_a[Azerbaijan]="Abseron Rayonu|Agcabadi Rayonu|Agdam Rayonu|Agdas Rayonu|Agstafa Rayonu|Agsu Rayonu|Ali Bayramli Sahari|Astara Rayonu|Baki Sahari|Balakan Rayonu|Barda Rayonu|Beylaqan Rayonu|Bilasuvar Rayonu|Cabrayil Rayonu|Calilabad Rayonu|Daskasan Rayonu|Davaci Rayonu|Fuzuli Rayonu|Gadabay Rayonu|Ganca Sahari|Goranboy Rayonu|Goycay Rayonu|Haciqabul Rayonu|Imisli Rayonu|Ismayilli Rayonu|Kalbacar Rayonu|Kurdamir Rayonu|Lacin Rayonu|Lankaran Rayonu|Lankaran Sahari|Lerik Rayonu|Masalli Rayonu|Mingacevir Sahari|Naftalan Sahari|Naxcivan Muxtar Respublikasi|Neftcala Rayonu|Oguz Rayonu|Qabala Rayonu|Qax Rayonu|Qazax Rayonu|Qobustan Rayonu|Quba Rayonu|Qubadli Rayonu|Qusar Rayonu|Saatli Rayonu|Sabirabad Rayonu|Saki Rayonu|Saki Sahari|Salyan Rayonu|Samaxi Rayonu|Samkir Rayonu|Samux Rayonu|Siyazan Rayonu|Sumqayit Sahari|Susa Rayonu|Susa Sahari|Tartar Rayonu|Tovuz Rayonu|Ucar Rayonu|Xacmaz Rayonu|Xankandi Sahari|Xanlar Rayonu|Xizi Rayonu|Xocali Rayonu|Xocavand Rayonu|Yardimli Rayonu|Yevlax Rayonu|Yevlax Sahari|Zangilan Rayonu|Zaqatala Rayonu|Zardab Rayonu";
//Bahamas
s_a[Bahamas]="Acklins and Crooked Islands|Bimini|Cat Island|Exuma|Freeport|Fresh Creek|Governor's Harbour|Green Turtle Cay|Harbour Island|High Rock|Inagua|Kemps Bay|Long Island|Marsh Harbour|Mayaguana|New Providence|Nicholls Town and Berry Islands|Ragged Island|Rock Sound|San Salvador and Rum Cay|Sandy Point";
//Bahrain
s_a[Bahrain]="Al Hadd|Al Manamah|Al Mintaqah al Gharbiyah|Al Mintaqah al Wusta|Al Mintaqah ash Shamaliyah|Al Muharraq|Ar Rifa' wa al Mintaqah al Janubiyah|Jidd Hafs|Juzur Hawar|Madinat 'Isa|Madinat Hamad|Sitrah";
//Bangladesh
s_a[Bangladesh]="Barguna|Barisal|Bhola|Jhalokati|Patuakhali|Pirojpur|Bandarban|Brahmanbaria|Chandpur|Chittagong|Comilla|Cox's Bazar|Feni|Khagrachari|Lakshmipur|Noakhali|Rangamati|Dhaka|Faridpur|Gazipur|Gopalganj|Jamalpur|Kishoreganj|Madaripur|Manikganj|Munshiganj|Mymensingh|Narayanganj|Narsingdi|Netrokona|Rajbari|Shariatpur|Sherpur|Tangail|Bagerhat|Chuadanga|Jessore|Jhenaidah|Khulna|Kushtia|Magura|Meherpur|Narail|Satkhira|Bogra|Dinajpur|Gaibandha|Jaipurhat|Kurigram|Lalmonirhat|Naogaon|Natore|Nawabganj|Nilphamari|Pabna|Panchagarh|Rajshahi|Rangpur|Sirajganj|Thakurgaon|Habiganj|Maulvi bazar|Sunamganj|Sylhet";
//Barbados
s_a[Barbados]="Bridgetown|Christ Church|Saint Andrew|Saint George|Saint James|Saint John|Saint Joseph|Saint Lucy|Saint Michael|Saint Peter|Saint Philip|Saint Thomas";
//Belarus
s_a[Belarus]="Brestskaya (Brest)|Homyel'skaya (Homyel')|Horad Minsk|Hrodzyenskaya (Hrodna)|Mahilyowskaya (Mahilyow)|Minskaya|Vitsyebskaya (Vitsyebsk)";
//Belgium
s_a[Belgium]="Antwerpen|Brabant Wallon|Brussels Capitol Region|Hainaut|Liege|Limburg|Luxembourg|Namur|Oost-Vlaanderen|Vlaams Brabant|West-Vlaanderen";
//Belize
s_a[Belize]="Belize|Cayo|Corozal|Orange Walk|Stann Creek|Toledo";
//Benin
s_a[Benin]="Alibori|Atakora|Atlantique|Borgou|Collines|Couffo|Donga|Littoral|Mono|Oueme|Plateau|Zou";
//Bermuda
s_a[Bermuda]="Devonshire|Hamilton|Hamilton|Paget|Pembroke|Saint George|Saint Georges|Sandys|Smiths|Southampton|Warwick";
//Bhutan
s_a[Bhutan]="Bumthang|Chhukha|Chirang|Daga|Geylegphug|Ha|Lhuntshi|Mongar|Paro|Pemagatsel|Punakha|Samchi|Samdrup Jongkhar|Shemgang|Tashigang|Thimphu|Tongsa|Wangdi Phodrang";
//Bolivia
s_a[Bolivia]="Beni|Chuquisaca|Cochabamba|La Paz|Oruro|Pando|Potosi|Santa Cruz|Tarija";
//Bonaire
s_a[Bonaire]="Bonaire";
//Bosnia and Herzegovina
s_a[Bosnia_and_Herzegovina]="Federation of Bosnia and Herzegovina|Republika Srpska";
//Botswana
s_a[Botswana]="Central|Chobe|Francistown|Gaborone|Ghanzi|Kgalagadi|Kgatleng|Kweneng|Lobatse|Ngamiland|North-East|Selebi-Pikwe|South-East|Southern";
//Bouvet Island
s_a[Bouvet_Island]="Bouvet Island";
//Brazil
s_a[Brazil]="Acre|Alagoas|Amapa|Amazonas|Bahia|Ceara|Distrito Federal|Espirito Santo|Goias|Maranhao|Mato Grosso|Mato Grosso do Sul|Minas Gerais|Para|Paraiba|Parana|Pernambuco|Piaui|Rio de Janeiro|Rio Grande do Norte|Rio Grande do Sul|Rondonia|Roraima|Santa Catarina|Sao Paulo|Sergipe|Tocantins";
//intBritish_Indian_Ocean_Territory
s_a[British_Indian_Ocean_Territory]="British Indian Ocean Territory";
//Brunei
s_a[Brunei_Darussalam]="Belait|Brunei and Muara|Temburong|Tutong";
//Bulgaria
s_a[Bulgaria]="Blagoevgrad|Burgas|Dobrich|Gabrovo|Khaskovo|Kurdzhali|Kyustendil|Lovech|Montana|Pazardzhik|Pernik|Pleven|Plovdiv|Razgrad|Ruse|Shumen|Silistra|Sliven|Smolyan|Sofiya|Sofiya-Grad|Stara Zagora|Turgovishte|Varna|Veliko Turnovo|Vidin|Vratsa|Yambol";
//Burkina Faso
s_a[Burkina_Faso]="Bale|Bam|Banwa|Bazega|Bougouriba|Boulgou|Boulkiemde|Comoe|Ganzourgou|Gnagna|Gourma|Houet|Ioba|Kadiogo|Kenedougou|Komandjari|Kompienga|Kossi|Koupelogo|Kouritenga|Kourweogo|Leraba|Loroum|Mouhoun|Nahouri|Namentenga|Naumbiel|Nayala|Oubritenga|Oudalan|Passore|Poni|Samentenga|Sanguie|Seno|Sissili|Soum|Sourou|Tapoa|Tuy|Yagha|Yatenga|Ziro|Zondomo|Zoundweogo";
//Burundi
s_a[Burundi]="Bubanza|Bujumbura|Bururi|Cankuzo|Cibitoke|Gitega|Karuzi|Kayanza|Kirundo|Makamba|Muramvya|Muyinga|Mwaro|Ngozi|Rutana|Ruyigi";
//Cambodia
s_a[Cambodia]="Banteay Mean Cheay|Batdambang|Kampong Cham|Kampong Chhnang|Kampong Spoe|Kampong Thum|Kampot|Kandal|Kaoh Kong|Keb|Kracheh|Mondol Kiri|Otdar Mean Cheay|Pailin|Phnum Penh|Pouthisat|Preah Seihanu (Sihanoukville)|Preah Vihear|Prey Veng|Rotanah Kiri|Siem Reab|Stoeng Treng|Svay Rieng|Takev";
//Cameroon
s_a[Cameroon]="Adamaoua|Centre|Est|Extreme-Nord|Littoral|Nord|Nord-Ouest|Ouest|Sud|Sud-Ouest";
//Canada
s_a[Canada]="Alberta|British Columbia|Manitoba|New Brunswick|Newfoundland|Northwest Territories|Nova Scotia|Nunavut|Ontario|Prince Edward Island|Quebec|Saskatchewan|Yukon Territory";
//Cape Verde
s_a[Cape_Verde]="Boa Vista|Brava|Maio|Mosteiros|Paul|Porto Novo|Praia|Ribeira Grande|Sal|Santa Catarina|Santa Cruz|Sao Domingos|Sao Filipe|Sao Nicolau|Sao Vicente|Tarrafal";
//Cayman Islands
s_a[Cayman_Islands]="Creek|Eastern|Midland|South Town|Spot Bay|Stake Bay|West End|Western";
//Central African Republic
s_a[Central_African_Republic]="Bamingui-Bangoran|Bangui|Basse-Kotto|Gribingui|Haut-Mbomou|Haute-Kotto|Haute-Sangha|Kemo-Gribingui|Lobaye|Mbomou|Nana-Mambere|Ombella-Mpoko|Ouaka|Ouham|Ouham-Pende|Sangha|Vakaga";
//Chad
s_a[Chad]="Batha|Biltine|Borkou-Ennedi-Tibesti|Chari-Baguirmi|Guera|Kanem|Lac|Logone Occidental|Logone Oriental|Mayo-Kebbi|Moyen-Chari|Ouaddai|Salamat|Tandjile";
//Chile
s_a[Chile]="Aisen del General Carlos Ibanez del Campo|Antofagasta|Araucania|Atacama|Bio-Bio|Coquimbo|Libertador General Bernardo O'Higgins|Los Lagos|Magallanes y de la Antartica Chilena|Maule|Region Metropolitana (Santiago)|Tarapaca|Valparaiso";
//China
s_a[China]="Anhui|Beijing|Chongqing|Fujian|Gansu|Guangdong|Guangxi|Guizhou|Hainan|Hebei|Heilongjiang|Henan|Hubei|Hunan|Jiangsu|Jiangxi|Jilin|Liaoning|Nei Mongol|Ningxia|Qinghai|Shaanxi|Shandong|Shanghai|Shanxi|Sichuan|Tianjin|Xinjiang|Xizang (Tibet)|Yunnan|Zhejiang";
//Christmas Island
s_a[Christmas_Island]="Christmas Island";
//Cocos (Keeling) Islands
s_a[Cocos__keeling__Islands]="Direction Island|Home Island|Horsburgh Island|North Keeling Island|South Island|West Island";
//Colombia
s_a[Colombia]="Amazonas|Antioquia|Arauca|Atlantico|Bolivar|Boyaca|Caldas|Caqueta|Casanare|Cauca|Cesar|Choco|Cordoba|Cundinamarca|Distrito Capital de Santa Fe de Bogota|Guainia|Guaviare|Huila|La Guajira|Magdalena|Meta|Narino|Norte de Santander|Putumayo|Quindio|Risaralda|San Andres y Providencia|Santander|Sucre|Tolima|Valle del Cauca|Vaupes|Vichada";
//Comoros
s_a[Comoros]="Anjouan (Nzwani)|Domoni|Fomboni|Grande Comore (Njazidja)|Moheli (Mwali)|Moroni|Moutsamoudou";
//Congo, Republic of the
s_a[Congo]="Bouenza|Brazzaville|Cuvette|Kouilou|Lekoumou|Likouala|Niari|Plateaux|Pool|Sangha";
//Congo, Democratic Republic of the
s_a[Congo__The_Democratic_Republic_of_The]="Bandundu|Bas-Congo|Equateur|Kasai-Occidental|Kasai-Oriental|Katanga|Kinshasa|Maniema|Nord-Kivu|Orientale|Sud-Kivu";
//Cook Islands
s_a[Cook_Islands]="Aitutaki|Atiu|Avarua|Mangaia|Manihiki|Manuae|Mauke|Mitiaro|Nassau Island|Palmerston|Penrhyn|Pukapuka|Rakahanga|Rarotonga|Suwarrow|Takutea";
//Costa Rica
s_a[Costa_Rica]="Alajuela|Cartago|Guanacaste|Heredia|Limon|Puntarenas|San Jose";
//Croatia
s_a[Croatia]="Bjelovarsko-Bilogorska Zupanija|Brodsko-Posavska Zupanija|Dubrovacko-Neretvanska Zupanija|Istarska Zupanija|Karlovacka Zupanija|Koprivnicko-Krizevacka Zupanija|Krapinsko-Zagorska Zupanija|Licko-Senjska Zupanija|Medimurska Zupanija|Osjecko-Baranjska Zupanija|Pozesko-Slavonska Zupanija|Primorsko-Goranska Zupanija|Sibensko-Kninska Zupanija|Sisacko-Moslavacka Zupanija|Splitsko-Dalmatinska Zupanija|Varazdinska Zupanija|Viroviticko-Podravska Zupanija|Vukovarsko-Srijemska Zupanija|Zadarska Zupanija|Zagreb|Zagrebacka Zupanija";
//Cuba
s_a[Cuba]="Camaguey|Ciego de Avila|Cienfuegos|Ciudad de La Habana|Granma|Guantanamo|Holguin|Isla de la Juventud|La Habana|Las Tunas|Matanzas|Pinar del Rio|Sancti Spiritus|Santiago de Cuba|Villa Clara";
//intCuracao
s_a[Curacao] = "Curaçao";
//Cyprus
s_a[Cyprus]="Famagusta|Kyrenia|Larnaca|Limassol|Nicosia|Paphos";
//Czeck Republic
s_a[Czech_Republic]="Brnensky|Budejovicky|Jihlavsky|Karlovarsky|Kralovehradecky|Liberecky|Olomoucky|Ostravsky|Pardubicky|Plzensky|Praha|Stredocesky|Ustecky|Zlinsky";
//Cote d"Ivoire
s_a[Cote_Divoire]="Abengourou|Abidjan|Aboisso|Adiake'|Adzope|Agboville|Agnibilekrou|Ale'pe'|Bangolo|Beoumi|Biankouma|Bocanda|Bondoukou|Bongouanou|Bouafle|Bouake|Bouna|Boundiali|Dabakala|Dabon|Daloa|Danane|Daoukro|Dimbokro|Divo|Duekoue|Ferkessedougou|Gagnoa|Grand Bassam|Grand-Lahou|Guiglo|Issia|Jacqueville|Katiola|Korhogo|Lakota|Man|Mankono|Mbahiakro|Odienne|Oume|Sakassou|San-Pedro|Sassandra|Seguela|Sinfra|Soubre|Tabou|Tanda|Tiassale|Tiebissou|Tingrela|Touba|Toulepleu|Toumodi|Vavoua|Yamoussoukro|Zuenoula";
//Denmark
s_a[Denmark]="Arhus|Bornholm|Fredericksberg|Frederiksborg|Fyn|Kobenhavn|Kobenhavns|Nordjylland|Ribe|Ringkobing|Roskilde|Sonderjylland|Storstrom|Vejle|Vestsjalland|Viborg";
//Djibouti
s_a[Djibouti]="'Ali Sabih|Dikhil|Djibouti|Obock|Tadjoura";
//Dominica
s_a[Dominica]="Saint Andrew|Saint David|Saint George|Saint John|Saint Joseph|Saint Luke|Saint Mark|Saint Patrick|Saint Paul|Saint Peter";
//Dominican Republic
s_a[Dominican_Republic]="Azua|Baoruco|Barahona|Dajabon|Distrito Nacional|Duarte|El Seibo|Elias Pina|Espaillat|Hato Mayor|Independencia|La Altagracia|La Romana|La Vega|Maria Trinidad Sanchez|Monsenor Nouel|Monte Cristi|Monte Plata|Pedernales|Peravia|Puerto Plata|Salcedo|Samana|San Cristobal|San Juan|San Pedro de Macoris|Sanchez Ramirez|Santiago|Santiago Rodriguez|Valverde";
//Ecuador
s_a[Ecuador]="Azuay|Bolivar|Canar|Carchi|Chimborazo|Cotopaxi|El Oro|Esmeraldas|Galapagos|Guayas|Imbabura|Loja|Los Rios|Manabi|Morona-Santiago|Napo|Orellana|Pastaza|Pichincha|Sucumbios|Tungurahua|Zamora-Chinchipe";
//Egypt
s_a[Egypt]="Ad Daqahliyah|Al Bahr al Ahmar|Al Buhayrah|Al Fayyum|Al Gharbiyah|Al Iskandariyah|Al Isma'iliyah|Al Jizah|Al Minufiyah|Al Minya|Al Qahirah|Al Qalyubiyah|Al Wadi al Jadid|As Suways|Ash Sharqiyah|Aswan|Asyut|Bani Suwayf|Bur Sa'id|Dumyat|Janub Sina'|Kafr ash Shaykh|Matruh|Qina|Shamal Sina'|Suhaj";
//El Salvador
s_a[El_Salvador]="Ahuachapan|Cabanas|Chalatenango|Cuscatlan|La Libertad|La Paz|La Union|Morazan|San Miguel|San Salvador|San Vicente|Santa Ana|Sonsonate|Usulutan";
//Equatorial Guinea
s_a[Equatorial_Guinea]="Annobon|Bioko Norte|Bioko Sur|Centro Sur|Kie-Ntem|Litoral|Wele-Nzas";
//Eritrea
s_a[Eritrea]="Akale Guzay|Barka|Denkel|Hamasen|Sahil|Semhar|Senhit|Seraye";
//Estonia
s_a[Estonia]="Harjumaa (Tallinn)|Hiiumaa (Kardla)|Ida-Virumaa (Johvi)|Jarvamaa (Paide)|Jogevamaa (Jogeva)|Laane-Virumaa (Rakvere)|Laanemaa (Haapsalu)|Parnumaa (Parnu)|Polvamaa (Polva)|Raplamaa (Rapla)|Saaremaa (Kuessaare)|Tartumaa (Tartu)|Valgamaa (Valga)|Viljandimaa (Viljandi)|Vorumaa (Voru)"
//Ethiopia
s_a[Ethiopia]="Adis Abeba (Addis Ababa)|Afar|Amara|Dire Dawa|Gambela Hizboch|Hareri Hizb|Oromiya|Sumale|Tigray|YeDebub Biheroch Bihereseboch na Hizboch";
//Falkland Islands (Islas Malvinas)
s_a[Falkland_Islands__malvinas_]="Falkland Islands (Islas Malvinas)"
//Faroe Islands
s_a[Faroe_Islands]="Bordoy|Eysturoy|Mykines|Sandoy|Skuvoy|Streymoy|Suduroy|Tvoroyri|Vagar";
//Fiji
s_a[Fiji]="Central|Eastern|Northern|Rotuma|Western";
//Finland
s_a[Finland]="Aland|Etela-Suomen Laani|Ita-Suomen Laani|Lansi-Suomen Laani|Lappi|Oulun Laani";
//France
s_a[France]="Alsace|Aquitaine|Auvergne|Basse-Normandie|Bourgogne|Bretagne|Centre|Champagne-Ardenne|Corse|Franche-Comte|Haute-Normandie|Ile-de-France|Languedoc-Roussillon|Limousin|Lorraine|Midi-Pyrenees|Nord-Pas-de-Calais|Pays de la Loire|Picardie|Poitou-Charentes|Provence-Alpes-Cote d'Azur|Rhone-Alpes";
//French Guiana
s_a[French_Guiana]="French Guiana";
//French Polynesia
s_a[French_Polynesia]="Archipel des Marquises|Archipel des Tuamotu|Archipel des Tubuai|Iles du Vent|Iles Sous-le-Vent";
//French Southern and Antarctic Lands
s_a[French_Southern_Territories]="Adelie Land|Ile Crozet|Iles Kerguelen|Iles Saint-Paul et Amsterdam";
//Gabon
s_a[Gabon]="Estuaire|Haut-Ogooue|Moyen-Ogooue|Ngounie|Nyanga|Ogooue-Ivindo|Ogooue-Lolo|Ogooue-Maritime|Woleu-Ntem";
//Gambia, The
s_a[Gambia]="Banjul|Central River|Lower River|North Bank|Upper River|Western";
//Georgia
s_a[Georgia]="Abashis|Abkhazia or Ap'khazet'is Avtonomiuri Respublika (Sokhumi)|Adigenis|Ajaria or Acharis Avtonomiuri Respublika (Bat'umi)|Akhalgoris|Akhalk'alak'is|Akhalts'ikhis|Akhmetis|Ambrolauris|Aspindzis|Baghdat'is|Bolnisis|Borjomis|Ch'khorotsqus|Ch'okhatauris|Chiat'ura|Dedop'listsqaros|Dmanisis|Dushet'is|Gardabanis|Gori|Goris|Gurjaanis|Javis|K'arelis|K'ut'aisi|Kaspis|Kharagaulis|Khashuris|Khobis|Khonis|Lagodekhis|Lanch'khut'is|Lentekhis|Marneulis|Martvilis|Mestiis|Mt'skhet'is|Ninotsmindis|Onis|Ozurget'is|P'ot'i|Qazbegis|Qvarlis|Rust'avi|Sach'kheris|Sagarejos|Samtrediis|Senakis|Sighnaghis|T'bilisi|T'elavis|T'erjolis|T'et'ritsqaros|T'ianet'is|Tqibuli|Ts'ageris|Tsalenjikhis|Tsalkis|Tsqaltubo|Vanis|Zestap'onis|Zugdidi|Zugdidis";
//Germany
s_a[Germany]="Baden-Wuerttemberg|Bayern|Berlin|Brandenburg|Bremen|Hamburg|Hessen|Mecklenburg-Vorpommern|Niedersachsen|Nordrhein-Westfalen|Rheinland-Pfalz|Saarland|Sachsen|Sachsen-Anhalt|Schleswig-Holstein|Thueringen";
//Ghana
s_a[Ghana]="Ashanti|Brong-Ahafo|Central|Eastern|Greater Accra|Northern|Upper East|Upper West|Volta|Western";
//Gibraltar
s_a[Gibraltar]="Gibraltar";
//Greece
s_a[Greece]="Aitolia kai Akarnania|Akhaia|Argolis|Arkadhia|Arta|Attiki|Ayion Oros (Mt. Athos)|Dhodhekanisos|Drama|Evritania|Evros|Evvoia|Florina|Fokis|Fthiotis|Grevena|Ilia|Imathia|Ioannina|Irakleion|Kardhitsa|Kastoria|Kavala|Kefallinia|Kerkyra|Khalkidhiki|Khania|Khios|Kikladhes|Kilkis|Korinthia|Kozani|Lakonia|Larisa|Lasithi|Lesvos|Levkas|Magnisia|Messinia|Pella|Pieria|Preveza|Rethimni|Rodhopi|Samos|Serrai|Thesprotia|Thessaloniki|Trikala|Voiotia|Xanthi|Zakinthos";
//Greenland
s_a[Greenland]="Avannaa (Nordgronland)|Kitaa (Vestgronland)|Tunu (Ostgronland)"
//Grenada
s_a[Grenada]="Carriacou and Petit Martinique|Saint Andrew|Saint David|Saint George|Saint John|Saint Mark|Saint Patrick";
//Guadeloupe
s_a[Guadeloupe]="Basse-Terre|Grande-Terre|Iles de la Petite Terre|Iles des Saintes|Marie-Galante";
//Guam
s_a[Guam]="Guam";
//Guatemala
s_a[Guatemala]="Alta Verapaz|Baja Verapaz|Chimaltenango|Chiquimula|El Progreso|Escuintla|Guatemala|Huehuetenango|Izabal|Jalapa|Jutiapa|Peten|Quetzaltenango|Quiche|Retalhuleu|Sacatepequez|San Marcos|Santa Rosa|Solola|Suchitepequez|Totonicapan|Zacapa";
//Guernsey
s_a[Guernsey]="Castel|Forest|St. Andrew|St. Martin|St. Peter Port|St. Pierre du Bois|St. Sampson|St. Saviour|Torteval|Vale";
//Guinea
s_a[Guinea]="Beyla|Boffa|Boke|Conakry|Coyah|Dabola|Dalaba|Dinguiraye|Dubreka|Faranah|Forecariah|Fria|Gaoual|Gueckedou|Kankan|Kerouane|Kindia|Kissidougou|Koubia|Koundara|Kouroussa|Labe|Lelouma|Lola|Macenta|Mali|Mamou|Mandiana|Nzerekore|Pita|Siguiri|Telimele|Tougue|Yomou";
//Guinea-Bissau
s_a[Guinea_bissau]="Bafata|Biombo|Bissau|Bolama-Bijagos|Cacheu|Gabu|Oio|Quinara|Tombali";
//Guyana
s_a[Guyana]="Barima-Waini|Cuyuni-Mazaruni|Demerara-Mahaica|East Berbice-Corentyne|Essequibo Islands-West Demerara|Mahaica-Berbice|Pomeroon-Supenaam|Potaro-Siparuni|Upper Demerara-Berbice|Upper Takutu-Upper Essequibo";
//Haiti
s_a[Haiti]="Artibonite|Centre|Grand'Anse|Nord|Nord-Est|Nord-Ouest|Ouest|Sud|Sud-Est";
//Heard Island and McDonald Islands
s_a[Heard_Island_and_Mcdonald_Islands]="Heard Island and McDonald Islands";
//Holy See (Vatican City)
s_a[Holy_See__vatican_City_State_]="Holy See (Vatican City)"
//Honduras
s_a[Honduras]="Atlantida|Choluteca|Colon|Comayagua|Copan|Cortes|El Paraiso|Francisco Morazan|Gracias a Dios|Intibuca|Islas de la Bahia|La Paz|Lempira|Ocotepeque|Olancho|Santa Barbara|Valle|Yoro";
//Hong Kong
s_a[Hong_Kong]="Hong Kong";
//Hungary
s_a[Hungary]="Bacs-Kiskun|Baranya|Bekes|Bekescsaba|Borsod-Abauj-Zemplen|Budapest|Csongrad|Debrecen|Dunaujvaros|Eger|Fejer|Gyor|Gyor-Moson-Sopron|Hajdu-Bihar|Heves|Hodmezovasarhely|Jasz-Nagykun-Szolnok|Kaposvar|Kecskemet|Komarom-Esztergom|Miskolc|Nagykanizsa|Nograd|Nyiregyhaza|Pecs|Pest|Somogy|Sopron|Szabolcs-Szatmar-Bereg|Szeged|Szekesfehervar|Szolnok|Szombathely|Tatabanya|Tolna|Vas|Veszprem|Veszprem|Zala|Zalaegerszeg";
//Iceland
s_a[Iceland]="Akranes|Akureyri|Arnessysla|Austur-Bardhastrandarsysla|Austur-Hunavatnssysla|Austur-Skaftafellssysla|Borgarfjardharsysla|Dalasysla|Eyjafjardharsysla|Gullbringusysla|Hafnarfjordhur|Husavik|Isafjordhur|Keflavik|Kjosarsysla|Kopavogur|Myrasysla|Neskaupstadhur|Nordhur-Isafjardharsysla|Nordhur-Mulasys-la|Nordhur-Thingeyjarsysla|Olafsfjordhur|Rangarvallasysla|Reykjavik|Saudharkrokur|Seydhisfjordhur|Siglufjordhur|Skagafjardharsysla|Snaefellsnes-og Hnappadalssysla|Strandasysla|Sudhur-Mulasysla|Sudhur-Thingeyjarsysla|Vesttmannaeyjar|Vestur-Bardhastrandarsysla|Vestur-Hunavatnssysla|Vestur-Isafjardharsysla|Vestur-Skaftafellssysla";
//India
s_a[India]="Andaman and Nicobar Islands|Andhra Pradesh|Arunachal Pradesh|Assam|Bihar|Chandigarh|Chhattisgarh|Dadra and Nagar Haveli|Daman and Diu|Delhi|Goa|Gujarat|Haryana|Himachal Pradesh|Jammu and Kashmir|Jharkhand|Karnataka|Kerala|Lakshadweep|Madhya Pradesh|Maharashtra|Manipur|Meghalaya|Mizoram|Nagaland|Orissa|Pondicherry|Punjab|Rajasthan|Sikkim|Tamil Nadu|Tripura|Uttar Pradesh|Uttaranchal|West Bengal";
//Indonesia
s_a[Indonesia]="Aceh|Bali|Banten|Bengkulu|East Timor|Gorontalo|Irian Jaya|Jakarta Raya|Jambi|Jawa Barat|Jawa Tengah|Jawa Timur|Kalimantan Barat|Kalimantan Selatan|Kalimantan Tengah|Kalimantan Timur|Kepulauan Bangka Belitung|Lampung|Maluku|Maluku Utara|Nusa Tenggara Barat|Nusa Tenggara Timur|Riau|Sulawesi Selatan|Sulawesi Tengah|Sulawesi Tenggara|Sulawesi Utara|Sumatera Barat|Sumatera Selatan|Sumatera Utara|Yogyakarta";
//Iran
s_a[Iran__Islamic_Republic_of]="Ardabil|Azarbayjan-e Gharbi|Azarbayjan-e Sharqi|Bushehr|Chahar Mahall va Bakhtiari|Esfahan|Fars|Gilan|Golestan|Hamadan|Hormozgan|Ilam|Kerman|Kermanshah|Khorasan|Khuzestan|Kohgiluyeh va Buyer Ahmad|Kordestan|Lorestan|Markazi|Mazandaran|Qazvin|Qom|Semnan|Sistan va Baluchestan|Tehran|Yazd|Zanjan";
//Iraq
s_a[Iraq]="Al Anbar|Al Basrah|Al Muthanna|Al Qadisiyah|An Najaf|Arbil|As Sulaymaniyah|At Ta'mim|Babil|Baghdad|Dahuk|Dhi Qar|Diyala|Karbala'|Maysan|Ninawa|Salah ad Din|Wasit";
//Ireland
s_a[Ireland]="Carlow|Cavan|Clare|Cork|Donegal|Dublin|Galway|Kerry|Kildare|Kilkenny|Laois|Leitrim|Limerick|Longford|Louth|Mayo|Meath|Monaghan|Offaly|Roscommon|Sligo|Tipperary|Waterford|Westmeath|Wexford|Wicklow";
//Isle of Man
s_a[Isle_of_Man]="Isle of Man";
//Israel
s_a[Israel]="Central|Haifa|Jerusalem|Northern|Southern|Tel Aviv";
//Italy
s_a[Italy]="Abruzzo|Basilicata|Calabria|Campania|Emilia-Romagna|Friuli-Venezia Giulia|Lazio|Liguria|Lombardia|Marche|Molise|Piemonte|Puglia|Sardegna|Sicilia|Toscana|Trentino-Alto Adige|Umbria|Valle d'Aosta|Veneto";
//Jamaica
s_a[Jamaica]="Clarendon|Hanover|Kingston|Manchester|Portland|Saint Andrew|Saint Ann|Saint Catherine|Saint Elizabeth|Saint James|Saint Mary|Saint Thomas|Trelawny|Westmoreland";
//Japan
s_a[Japan]="Aichi|Akita|Aomori|Chiba|Ehime|Fukui|Fukuoka|Fukushima|Gifu|Gumma|Hiroshima|Hokkaido|Hyogo|Ibaraki|Ishikawa|Iwate|Kagawa|Kagoshima|Kanagawa|Kochi|Kumamoto|Kyoto|Mie|Miyagi|Miyazaki|Nagano|Nagasaki|Nara|Niigata|Oita|Okayama|Okinawa|Osaka|Saga|Saitama|Shiga|Shimane|Shizuoka|Tochigi|Tokushima|Tokyo|Tottori|Toyama|Wakayama|Yamagata|Yamaguchi|Yamanashi";
//Jersey
s_a[Jersey]="Jersey";
//Jordan
s_a[Jordan]="'Amman|Ajlun|Al 'Aqabah|Al Balqa'|Al Karak|Al Mafraq|At Tafilah|Az Zarqa'|Irbid|Jarash|Ma'an|Madaba";
//Kazakhstan
s_a[Kazakhstan]="Almaty|Aqmola|Aqtobe|Astana|Atyrau|Batys Qazaqstan|Bayqongyr|Mangghystau|Ongtustik Qazaqstan|Pavlodar|Qaraghandy|Qostanay|Qyzylorda|Shyghys Qazaqstan|Soltustik Qazaqstan|Zhambyl";
//Kenya
s_a[Kenya]="Central|Coast|Eastern|Nairobi Area|North Eastern|Nyanza|Rift Valley|Western";
//Kiribati
s_a[Kiribati]="Abaiang|Abemama|Aranuka|Arorae|Banaba|Banaba|Beru|Butaritari|Central Gilberts|Gilbert Islands|Kanton|Kiritimati|Kuria|Line Islands|Line Islands|Maiana|Makin|Marakei|Nikunau|Nonouti|Northern Gilberts|Onotoa|Phoenix Islands|Southern Gilberts|Tabiteuea|Tabuaeran|Tamana|Tarawa|Tarawa|Teraina";
//Korea, North
s_a[Korea__Democratic_Peoples_Republic_of]="Chagang-do (Chagang Province)|Hamgyong-bukto (North Hamgyong Province)|Hamgyong-namdo (South Hamgyong Province)|Hwanghae-bukto (North Hwanghae Province)|Hwanghae-namdo (South Hwanghae Province)|Kaesong-si (Kaesong City)|Kangwon-do (Kangwon Province)|Namp'o-si (Namp'o City)|P'yongan-bukto (North P'yongan Province)|P'yongan-namdo (South P'yongan Province)|P'yongyang-si (P'yongyang City)|Yanggang-do (Yanggang Province)"
//Korea, South
s_a[Korea__Republic_of]="Ch'ungch'ong-bukto|Ch'ungch'ong-namdo|Cheju-do|Cholla-bukto|Cholla-namdo|Inch'on-gwangyoksi|Kangwon-do|Kwangju-gwangyoksi|Kyonggi-do|Kyongsang-bukto|Kyongsang-namdo|Pusan-gwangyoksi|Soul-t'ukpyolsi|Taegu-gwangyoksi|Taejon-gwangyoksi|Ulsan-gwangyoksi";
//Kuwait
s_a[Kuwait]="Al 'Asimah|Al Ahmadi|Al Farwaniyah|Al Jahra'|Hawalli";
//Kyrgyzstan
s_a[Kyrgyzstan]="Batken Oblasty|Bishkek Shaary|Chuy Oblasty (Bishkek)|Jalal-Abad Oblasty|Naryn Oblasty|Osh Oblasty|Talas Oblasty|Ysyk-Kol Oblasty (Karakol)"
//Laos
s_a[Lao_Peoples_Democratic_Republic]="Attapu|Bokeo|Bolikhamxai|Champasak|Houaphan|Khammouan|Louangnamtha|Louangphabang|Oudomxai|Phongsali|Salavan|Savannakhet|Viangchan|Viangchan|Xaignabouli|Xaisomboun|Xekong|Xiangkhoang";
//Latvia
s_a[Latvia]="Aizkraukles Rajons|Aluksnes Rajons|Balvu Rajons|Bauskas Rajons|Cesu Rajons|Daugavpils|Daugavpils Rajons|Dobeles Rajons|Gulbenes Rajons|Jekabpils Rajons|Jelgava|Jelgavas Rajons|Jurmala|Kraslavas Rajons|Kuldigas Rajons|Leipaja|Liepajas Rajons|Limbazu Rajons|Ludzas Rajons|Madonas Rajons|Ogres Rajons|Preilu Rajons|Rezekne|Rezeknes Rajons|Riga|Rigas Rajons|Saldus Rajons|Talsu Rajons|Tukuma Rajons|Valkas Rajons|Valmieras Rajons|Ventspils|Ventspils Rajons";
//Lebanon
s_a[Lebanon]="Beyrouth|Ech Chimal|Ej Jnoub|El Bekaa|Jabal Loubnane";
//Lesotho
s_a[Lesotho]="Berea|Butha-Buthe|Leribe|Mafeteng|Maseru|Mohales Hoek|Mokhotlong|Qacha's Nek|Quthing|Thaba-Tseka";
//Liberia
s_a[Liberia]="Bomi|Bong|Grand Bassa|Grand Cape Mount|Grand Gedeh|Grand Kru|Lofa|Margibi|Maryland|Montserrado|Nimba|River Cess|Sinoe";
//Libya
s_a[Libya]="Ajdabiya|Al 'Aziziyah|Al Fatih|Al Jabal al Akhdar|Al Jufrah|Al Khums|Al Kufrah|An Nuqat al Khams|Ash Shati'|Awbari|Az Zawiyah|Banghazi|Darnah|Ghadamis|Gharyan|Misratah|Murzuq|Sabha|Sawfajjin|Surt|Tarabulus|Tarhunah|Tubruq|Yafran|Zlitan";
//Liechtenstein
s_a[Liechtenstein]="Balzers|Eschen|Gamprin|Mauren|Planken|Ruggell|Schaan|Schellenberg|Triesen|Triesenberg|Vaduz";
//Lithuania
s_a[Lithuania]="Akmenes Rajonas|Alytaus Rajonas|Alytus|Anyksciu Rajonas|Birstonas|Birzu Rajonas|Druskininkai|Ignalinos Rajonas|Jonavos Rajonas|Joniskio Rajonas|Jurbarko Rajonas|Kaisiadoriu Rajonas|Kaunas|Kauno Rajonas|Kedainiu Rajonas|Kelmes Rajonas|Klaipeda|Klaipedos Rajonas|Kretingos Rajonas|Kupiskio Rajonas|Lazdiju Rajonas|Marijampole|Marijampoles Rajonas|Mazeikiu Rajonas|Moletu Rajonas|Neringa Pakruojo Rajonas|Palanga|Panevezio Rajonas|Panevezys|Pasvalio Rajonas|Plunges Rajonas|Prienu Rajonas|Radviliskio Rajonas|Raseiniu Rajonas|Rokiskio Rajonas|Sakiu Rajonas|Salcininku Rajonas|Siauliai|Siauliu Rajonas|Silales Rajonas|Silutes Rajonas|Sirvintu Rajonas|Skuodo Rajonas|Svencioniu Rajonas|Taurages Rajonas|Telsiu Rajonas|Traku Rajonas|Ukmerges Rajonas|Utenos Rajonas|Varenos Rajonas|Vilkaviskio Rajonas|Vilniaus Rajonas|Vilnius|Zarasu Rajonas";
//Luxembourg
s_a[Luxembourg]="Diekirch|Grevenmacher|Luxembourg";
//Macau
s_a[Macao]="Macau";
//Macedonia, Former Yugoslav Republic of
s_a[Macedonia__The_Former_Yugoslav_Republic_of]="Aracinovo|Bac|Belcista|Berovo|Bistrica|Bitola|Blatec|Bogdanci|Bogomila|Bogovinje|Bosilovo|Brvenica|Cair (Skopje)|Capari|Caska|Cegrane|Centar (Skopje)|Centar Zupa|Cesinovo|Cucer-Sandevo|Debar|Delcevo|Delogozdi|Demir Hisar|Demir Kapija|Dobrusevo|Dolna Banjica|Dolneni|Dorce Petrov (Skopje)|Drugovo|Dzepciste|Gazi Baba (Skopje)|Gevgelija|Gostivar|Gradsko|Ilinden|Izvor|Jegunovce|Kamenjane|Karbinci|Karpos (Skopje)|Kavadarci|Kicevo|Kisela Voda (Skopje)|Klecevce|Kocani|Konce|Kondovo|Konopiste|Kosel|Kratovo|Kriva Palanka|Krivogastani|Krusevo|Kuklis|Kukurecani|Kumanovo|Labunista|Lipkovo|Lozovo|Lukovo|Makedonska Kamenica|Makedonski Brod|Mavrovi Anovi|Meseista|Miravci|Mogila|Murtino|Negotino|Negotino-Poloska|Novaci|Novo Selo|Oblesevo|Ohrid|Orasac|Orizari|Oslomej|Pehcevo|Petrovec|Plasnia|Podares|Prilep|Probistip|Radovis|Rankovce|Resen|Rosoman|Rostusa|Samokov|Saraj|Sipkovica|Sopiste|Sopotnika|Srbinovo|Star Dojran|Staravina|Staro Nagoricane|Stip|Struga|Strumica|Studenicani|Suto Orizari (Skopje)|Sveti Nikole|Tearce|Tetovo|Topolcani|Valandovo|Vasilevo|Veles|Velesta|Vevcani|Vinica|Vitoliste|Vranestica|Vrapciste|Vratnica|Vrutok|Zajas|Zelenikovo|Zileno|Zitose|Zletovo|Zrnovci";
//Madagascar
s_a[Madagascar]="Antananarivo|Antsiranana|Fianarantsoa|Mahajanga|Toamasina|Toliara";
//Malawi
s_a[Malawi]="Balaka|Blantyre|Chikwawa|Chiradzulu|Chitipa|Dedza|Dowa|Karonga|Kasungu|Likoma|Lilongwe|Machinga (Kasupe)|Mangochi|Mchinji|Mulanje|Mwanza|Mzimba|Nkhata Bay|Nkhotakota|Nsanje|Ntcheu|Ntchisi|Phalombe|Rumphi|Salima|Thyolo|Zomba";
//Malaysia
s_a[Malaysia]="Johor|Kedah|Kelantan|Labuan|Melaka|Negeri Sembilan|Pahang|Perak|Perlis|Pulau Pinang|Sabah|Sarawak|Selangor|Terengganu|Wilayah Persekutuan";
//Maldives
s_a[Maldives]="Alifu|Baa|Dhaalu|Faafu|Gaafu Alifu|Gaafu Dhaalu|Gnaviyani|Haa Alifu|Haa Dhaalu|Kaafu|Laamu|Lhaviyani|Maale|Meemu|Noonu|Raa|Seenu|Shaviyani|Thaa|Vaavu";
//Mali
s_a[Mali]="Gao|Kayes|Kidal|Koulikoro|Mopti|Segou|Sikasso|Tombouctou";
//Malta
s_a[Malta]="Valletta";
//Marshall Islands
s_a[Marshall_Islands]="Ailinginae|Ailinglaplap|Ailuk|Arno|Aur|Bikar|Bikini|Bokak|Ebon|Enewetak|Erikub|Jabat|Jaluit|Jemo|Kili|Kwajalein|Lae|Lib|Likiep|Majuro|Maloelap|Mejit|Mili|Namorik|Namu|Rongelap|Rongrik|Toke|Ujae|Ujelang|Utirik|Wotho|Wotje";
//Martinique
s_a[Martinique]="Martinique";
//Mauritania
s_a[Mauritania]="Adrar|Assaba|Brakna|Dakhlet Nouadhibou|Gorgol|Guidimaka|Hodh Ech Chargui|Hodh El Gharbi|Inchiri|Nouakchott|Tagant|Tiris Zemmour|Trarza";
//Mauritius
s_a[Mauritius]="Agalega Islands|Black River|Cargados Carajos Shoals|Flacq|Grand Port|Moka|Pamplemousses|Plaines Wilhems|Port Louis|Riviere du Rempart|Rodrigues|Savanne";
//Mayotte
s_a[Mayotte]="Mayotte";
//Mexico
s_a[Mexico]="Aguascalientes|Baja California|Baja California Sur|Campeche|Chiapas|Chihuahua|Coahuila de Zaragoza|Colima|Distrito Federal|Durango|Guanajuato|Guerrero|Hidalgo|Jalisco|Mexico|Michoacan de Ocampo|Morelos|Nayarit|Nuevo Leon|Oaxaca|Puebla|Queretaro de Arteaga|Quintana Roo|San Luis Potosi|Sinaloa|Sonora|Tabasco|Tamaulipas|Tlaxcala|Veracruz-Llave|Yucatan|Zacatecas";
//Micronesia, Federated States of
s_a[Micronesia__Federated_States_of]="Chuuk (Truk)|Kosrae|Pohnpei|Yap";
//Moldova
s_a[Moldova__Republic_of]="Balti|Cahul|Chisinau|Chisinau|Dubasari|Edinet|Gagauzia|Lapusna|Orhei|Soroca|Tighina|Ungheni";
//Monaco
s_a[Monaco]="Fontvieille|La Condamine|Monaco-Ville|Monte-Carlo";
//Mongolia
s_a[Mongolia]="Arhangay|Bayan-Olgiy|Bayanhongor|Bulgan|Darhan|Dornod|Dornogovi|Dundgovi|Dzavhan|Erdenet|Govi-Altay|Hentiy|Hovd|Hovsgol|Omnogovi|Ovorhangay|Selenge|Suhbaatar|Tov|Ulaanbaatar|Uvs";
//intMontenegro
s_a[Montenegro]="Montenegro";
//Montserrat
s_a[Montserrat]="Saint Anthony|Saint Georges|Saint Peter's";
//Morocco
s_a[Morocco]="Agadir|Al Hoceima|Azilal|Ben Slimane|Beni Mellal|Boulemane|Casablanca|Chaouen|El Jadida|El Kelaa des Srarhna|Er Rachidia|Essaouira|Fes|Figuig|Guelmim|Ifrane|Kenitra|Khemisset|Khenifra|Khouribga|Laayoune|Larache|Marrakech|Meknes|Nador|Ouarzazate|Oujda|Rabat-Sale|Safi|Settat|Sidi Kacem|Tan-Tan|Tanger|Taounate|Taroudannt|Tata|Taza|Tetouan|Tiznit";
//Mozambique
s_a[Mozambique]="Cabo Delgado|Gaza|Inhambane|Manica|Maputo|Nampula|Niassa|Sofala|Tete|Zambezia";
//Burma
s_a[Myanmar]="Ayeyarwady|Bago|Chin State|Kachin State|Kayah State|Kayin State|Magway|Mandalay|Mon State|Rakhine State|Sagaing|Shan State|Tanintharyi|Yangon";
//Namibia
s_a[Namibia]="Caprivi|Erongo|Hardap|Karas|Khomas|Kunene|Ohangwena|Okavango|Omaheke|Omusati|Oshana|Oshikoto|Otjozondjupa";
//Nauru
s_a[Nauru]="Aiwo|Anabar|Anetan|Anibare|Baiti|Boe|Buada|Denigomodu|Ewa|Ijuw|Meneng|Nibok|Uaboe|Yaren";
//Nepal
s_a[Nepal]="Bagmati|Bheri|Dhawalagiri|Gandaki|Janakpur|Karnali|Kosi|Lumbini|Mahakali|Mechi|Narayani|Rapti|Sagarmatha|Seti";
//Netherlands
s_a[Netherlands]="Drenthe|Flevoland|Friesland|Gelderland|Groningen|Limburg|Noord-Brabant|Noord-Holland|Overijssel|Utrecht|Zeeland|Zuid-Holland";
//Netherlands Antilles
s_a[Netherlands_Antilles]="Netherlands Antilles";
//New Caledonia
s_a[New_Caledonia]="Iles Loyaute|Nord|Sud";
//New Zealand
s_a[New_Zealand]="Alexandra|Ashburton|Auckland|Blenheim|Christchurch|Dannevirke|Dunedin|Feilding|Gisborne|Gore|Greymouth|Hamilton|Hastings|Hawera|Huntly|Invercargill|Kaitaia|Kapiti|Kawerau|Kerikeri|Levin|Masterton|Matamata|Morrinsville|Motueka|Napier|Nelson|New Plymouth|Oamaru|Otaki|Palmerston North|Pukekohe|Queenstown|Rangiora|Rolleston|Rotorua|Stratford|Taupo|Tauranga|Te Puke|Thames|Timaru|Tokoroa|Waiheke Island|Waitara|Waiuku|Wanaka|Wellington|Whakatane|Whanganui|Whangarei";
//Nicaragua
s_a[Nicaragua]="Atlantico Norte|Atlantico Sur|Boaco|Carazo|Chinandega|Chontales|Esteli|Granada|Jinotega|Leon|Madriz|Managua|Masaya|Matagalpa|Nueva Segovia|Rio San Juan|Rivas";
//Niger
s_a[Niger]="Agadez|Diffa|Dosso|Maradi|Niamey|Tahoua|Tillaberi|Zinder";
//Nigeria
s_a[Nigeria]="Abia|Abuja Federal Capital Territory|Adamawa|Akwa Ibom|Anambra|Bauchi|Bayelsa|Benue|Borno|Cross River|Delta|Ebonyi|Edo|Ekiti|Enugu|Gombe|Imo|Jigawa|Kaduna|Kano|Katsina|Kebbi|Kogi|Kwara|Lagos|Nassarawa|Niger|Ogun|Ondo|Osun|Oyo|Plateau|Rivers|Sokoto|Taraba|Yobe|Zamfara";
//Niue
s_a[Niue]="Niue";
//Norfolk Island
s_a[Norfolk_Island]="Norfolk Island";
//Northern Mariana Islands
s_a[Northern_Mariana_Islands]="Northern Islands|Rota|Saipan|Tinian";
//Norway
s_a[Norway]="Akershus|Aust-Agder|Buskerud|Finnmark|Hedmark|Hordaland|More og Romsdal|Nord-Trondelag|Nordland|Oppland|Oslo|Ostfold|Rogaland|Sogn og Fjordane|Sor-Trondelag|Telemark|Troms|Vest-Agder|Vestfold";
//Oman
s_a[Oman]="Ad Dakhiliyah|Al Batinah|Al Wusta|Ash Sharqiyah|Az Zahirah|Masqat|Musandam|Zufar";
//Pakistan
s_a[Pakistan]="Balochistan|Federally Administered Tribal Areas|Islamabad Capital Territory|North-West Frontier Province|Punjab|Sindh";
//Palau
s_a[Palau]="Aimeliik|Airai|Angaur|Hatobohei|Kayangel|Koror|Melekeok|Ngaraard|Ngarchelong|Ngardmau|Ngatpang|Ngchesar|Ngeremlengui|Ngiwal|Palau Island|Peleliu|Sonsoral|Tobi";
//Panama
s_a[Panama]="Bocas del Toro|Chiriqui|Cocle|Colon|Darien|Herrera|Los Santos|Panama|San Blas|Veraguas";
//Papua New Guinea
s_a[Papua_New_Guinea]="Bougainville|Central|Chimbu|East New Britain|East Sepik|Eastern Highlands|Enga|Gulf|Madang|Manus|Milne Bay|Morobe|National Capital|New Ireland|Northern|Sandaun|Southern Highlands|West New Britain|Western|Western Highlands";
//Paraguay
s_a[Paraguay]="Alto Paraguay|Alto Parana|Amambay|Asuncion (city)|Boqueron|Caaguazu|Caazapa|Canindeyu|Central|Concepcion|Cordillera|Guaira|Itapua|Misiones|Neembucu|Paraguari|Presidente Hayes|San Pedro";
//Peru
s_a[Peru]="Amazonas|Ancash|Apurimac|Arequipa|Ayacucho|Cajamarca|Callao|Cusco|Huancavelica|Huanuco|Ica|Junin|La Libertad|Lambayeque|Lima|Loreto|Madre de Dios|Moquegua|Pasco|Piura|Puno|San Martin|Tacna|Tumbes|Ucayali";
//Philippines
s_a[Philippines]="Abra|Agusan del Norte|Agusan del Sur|Aklan|Albay|Angeles|Antique|Aurora|Bacolod|Bago|Baguio|Bais|Basilan|Basilan City|Bataan|Batanes|Batangas|Batangas City|Benguet|Bohol|Bukidnon|Bulacan|Butuan|Cabanatuan|Cadiz|Cagayan|Cagayan de Oro|Calbayog|Caloocan|Camarines Norte|Camarines Sur|Camiguin|Canlaon|Capiz|Catanduanes|Cavite|Cavite City|Cebu|Cebu City|Cotabato|Dagupan|Danao|Dapitan|Davao City Davao|Davao del Sur|Davao Oriental|Dipolog|Dumaguete|Eastern Samar|General Santos|Gingoog|Ifugao|Iligan|Ilocos Norte|Ilocos Sur|Iloilo|Iloilo City|Iriga|Isabela|Kalinga-Apayao|La Carlota|La Union|Laguna|Lanao del Norte|Lanao del Sur|Laoag|Lapu-Lapu|Legaspi|Leyte|Lipa|Lucena|Maguindanao|Mandaue|Manila|Marawi|Marinduque|Masbate|Mindoro Occidental|Mindoro Oriental|Misamis Occidental|Misamis Oriental|Mountain|Naga|Negros Occidental|Negros Oriental|North Cotabato|Northern Samar|Nueva Ecija|Nueva Vizcaya|Olongapo|Ormoc|Oroquieta|Ozamis|Pagadian|Palawan|Palayan|Pampanga|Pangasinan|Pasay|Puerto Princesa|Quezon|Quezon City|Quirino|Rizal|Romblon|Roxas|Samar|San Carlos (in Negros Occidental)|San Carlos (in Pangasinan)|San Jose|San Pablo|Silay|Siquijor|Sorsogon|South Cotabato|Southern Leyte|Sultan Kudarat|Sulu|Surigao|Surigao del Norte|Surigao del Sur|Tacloban|Tagaytay|Tagbilaran|Tangub|Tarlac|Tawitawi|Toledo|Trece Martires|Zambales|Zamboanga|Zamboanga del Norte|Zamboanga del Sur";
//Pitcaim Islands
s_a[Pitcairn]="Pitcaim Islands";
//Poland
s_a[Poland]="Dolnoslaskie|Kujawsko-Pomorskie|Lodzkie|Lubelskie|Lubuskie|Malopolskie|Mazowieckie|Opolskie|Podkarpackie|Podlaskie|Pomorskie|Slaskie|Swietokrzyskie|Warminsko-Mazurskie|Wielkopolskie|Zachodniopomorskie";
//Portugal
s_a[Portugal]="Acores (Azores)|Aveiro|Beja|Braga|Braganca|Castelo Branco|Coimbra|Evora|Faro|Guarda|Leiria|Lisboa|Madeira|Portalegre|Porto|Santarem|Setubal|Viana do Castelo|Vila Real|Viseu";
//Puerto Rico
s_a[Puerto_Rico]="Adjuntas|Aguada|Aguadilla|Aguas Buenas|Aibonito|Anasco|Arecibo|Arroyo|Barceloneta|Barranquitas|Bayamon|Cabo Rojo|Caguas|Camuy|Canovanas|Carolina|Catano|Cayey|Ceiba|Ciales|Cidra|Coamo|Comerio|Corozal|Culebra|Dorado|Fajardo|Florida|Guanica|Guayama|Guayanilla|Guaynabo|Gurabo|Hatillo|Hormigueros|Humacao|Isabela|Jayuya|Juana Diaz|Juncos|Lajas|Lares|Las Marias|Las Piedras|Loiza|Luquillo|Manati|Maricao|Maunabo|Mayaguez|Moca|Morovis|Naguabo|Naranjito|Orocovis|Patillas|Penuelas|Ponce|Quebradillas|Rincon|Rio Grande|Sabana Grande|Salinas|San German|San Juan|San Lorenzo|San Sebastian|Santa Isabel|Toa Alta|Toa Baja|Trujillo Alto|Utuado|Vega Alta|Vega Baja|Vieques|Villalba|Yabucoa|Yauco";
//Qatar
s_a[Qatar]="Ad Dawhah|Al Ghuwayriyah|Al Jumayliyah|Al Khawr|Al Wakrah|Ar Rayyan|Jarayan al Batinah|Madinat ash Shamal|Umm Salal";
//Romainia
s_a[Romania]="Alba|Arad|Arges|Bacau|Bihor|Bistrita-Nasaud|Botosani|Braila|Brasov|Bucuresti|Buzau|Calarasi|Caras-Severin|Cluj|Constanta|Covasna|Dimbovita|Dolj|Galati|Giurgiu|Gorj|Harghita|Hunedoara|Ialomita|Iasi|Maramures|Mehedinti|Mures|Neamt|Olt|Prahova|Salaj|Satu Mare|Sibiu|Suceava|Teleorman|Timis|Tulcea|Vaslui|Vilcea|Vrancea";
//Russia
s_a[Russian_Federation]="Adygeya (Maykop)|Aginskiy Buryatskiy (Aginskoye)|Altay (Gorno-Altaysk)|Altayskiy (Barnaul)|Amurskaya (Blagoveshchensk)|Arkhangel'skaya|Astrakhanskaya|Bashkortostan (Ufa)|Belgorodskaya|Bryanskaya|Buryatiya (Ulan-Ude)|Chechnya (Groznyy)|Chelyabinskaya|Chitinskaya|Chukotskiy (Anadyr')|Chuvashiya (Cheboksary)|Dagestan (Makhachkala)|Evenkiyskiy (Tura)|Ingushetiya (Nazran')|Irkutskaya|Ivanovskaya|Kabardino-Balkariya (Nal'chik)|Kaliningradskaya|Kalmykiya (Elista)|Kaluzhskaya|Kamchatskaya (Petropavlovsk-Kamchatskiy)|Karachayevo-Cherkesiya (Cherkessk)|Kareliya (Petrozavodsk)|Kemerovskaya|Khabarovskiy|Khakasiya (Abakan)|Khanty-Mansiyskiy (Khanty-Mansiysk)|Kirovskaya|Komi (Syktyvkar)|Komi-Permyatskiy (Kudymkar)|Koryakskiy (Palana)|Kostromskaya|Krasnodarskiy|Krasnoyarskiy|Kurganskaya|Kurskaya|Leningradskaya|Lipetskaya|Magadanskaya|Mariy-El (Yoshkar-Ola)|Mordoviya (Saransk)|Moskovskaya|Moskva (Moscow)|Murmanskaya|Nenetskiy (Nar'yan-Mar)|Nizhegorodskaya|Novgorodskaya|Novosibirskaya|Omskaya|Orenburgskaya|Orlovskaya (Orel)|Penzenskaya|Permskaya|Primorskiy (Vladivostok)|Pskovskaya|Rostovskaya|Ryazanskaya|Sakha (Yakutsk)|Sakhalinskaya (Yuzhno-Sakhalinsk)|Samarskaya|Sankt-Peterburg (Saint Petersburg)|Saratovskaya|Severnaya Osetiya-Alaniya [North Ossetia] (Vladikavkaz)|Smolenskaya|Stavropol'skiy|Sverdlovskaya (Yekaterinburg)|Tambovskaya|Tatarstan (Kazan')|Taymyrskiy (Dudinka)|Tomskaya|Tul'skaya|Tverskaya|Tyumenskaya|Tyva (Kyzyl)|Udmurtiya (Izhevsk)|Ul'yanovskaya|Ust'-Ordynskiy Buryatskiy (Ust'-Ordynskiy)|Vladimirskaya|Volgogradskaya|Vologodskaya|Voronezhskaya|Yamalo-Nenetskiy (Salekhard)|Yaroslavskaya|Yevreyskaya";
//Rwanda
s_a[Rwanda]="Butare|Byumba|Cyangugu|Gikongoro|Gisenyi|Gitarama|Kibungo|Kibuye|Kigali Rurale|Kigali-ville|Ruhengeri|Umutara";
//Reunion
s_a[Reunion]="Reunion";
//intSaint_Barthélemy
s_a[Saint_Barthelemy]="Saint Barthélemy";
//Saint Helena
s_a[Saint_Helena]="Ascension|Saint Helena|Tristan da Cunha";
//Saint Kitts and Nevis
s_a[Saint_Kitts_and_Nevis]="Christ Church Nichola Town|Saint Anne Sandy Point|Saint George Basseterre|Saint George Gingerland|Saint James Windward|Saint John Capisterre|Saint John Figtree|Saint Mary Cayon|Saint Paul Capisterre|Saint Paul Charlestown|Saint Peter Basseterre|Saint Thomas Lowland|Saint Thomas Middle Island|Trinity Palmetto Point";
//Saint Lucia
s_a[Saint_Lucia]="Anse-la-Raye|Castries|Choiseul|Dauphin|Dennery|Gros Islet|Laborie|Micoud|Praslin|Soufriere|Vieux Fort";
//intSaint_Martin__French_Part_
s_a[Saint_Martin__French_Part_]="Saint Martin (French Part)";
//Saint Pierre and Miquelon
s_a[Saint_Pierre_and_Miquelon]="Miquelon|Saint Pierre";
//Saint Vincent and the Grenadines
s_a[Saint_Vincent_and_The_Grenadines]="Charlotte|Grenadines|Saint Andrew|Saint David|Saint George|Saint Patrick";
//Samoa
s_a[Samoa]="A'ana|Aiga-i-le-Tai|Atua|Fa'asaleleaga|Gaga'emauga|Gagaifomauga|Palauli|Satupa'itea|Tuamasaga|Va'a-o-Fonoti|Vaisigano";
//San Marino
s_a[San_Marino]="Acquaviva|Borgo Maggiore|Chiesanuova|Domagnano|Faetano|Fiorentino|Monte Giardino|San Marino|Serravalle";
//Sao Tome and Principe
s_a[Sao_Tome_and_Principe]="Principe|Sao Tome";
//Saudi Arabia
s_a[Saudi_Arabia]="'Asir|Al Bahah|Al Hudud ash Shamaliyah|Al Jawf|Al Madinah|Al Qasim|Ar Riyad|Ash Sharqiyah (Eastern Province)|Ha'il|Jizan|Makkah|Najran|Tabuk";
//Senegal
s_a[Senegal]="Dakar|Diourbel|Fatick|Kaolack|Kolda|Louga|Saint-Louis|Tambacounda|Thies|Ziguinchor";
//intSerbia
s_a[Serbia]="Serbia";
//Seychelles
s_a[Seychelles]="Anse aux Pins|Anse Boileau|Anse Etoile|Anse Louis|Anse Royale|Baie Lazare|Baie Sainte Anne|Beau Vallon|Bel Air|Bel Ombre|Cascade|Glacis|Grand' Anse (on Mahe)|Grand' Anse (on Praslin)|La Digue|La Riviere Anglaise|Mont Buxton|Mont Fleuri|Plaisance|Pointe La Rue|Port Glaud|Saint Louis|Takamaka";
//Sierra Leone
s_a[Sierra_Leone]="Eastern|Northern|Southern|Western";
//Singapore
s_a[Singapore]="Singapore";
//intSint_Maartin__Dutch_Part_
s_a[Sint_Maartin__Dutch_Part_]="Sint Maartin (Dutch Part)";
//Slovakia
s_a[Slovakia]="Banskobystricky|Bratislavsky|Kosicky|Nitriansky|Presovsky|Trenciansky|Trnavsky|Zilinsky";
//Slovenia
s_a[Slovenia]="Ajdovscina|Beltinci|Bled|Bohinj|Borovnica|Bovec|Brda|Brezice|Brezovica|Cankova-Tisina|Celje|Cerklje na Gorenjskem|Cerknica|Cerkno|Crensovci|Crna na Koroskem|Crnomelj|Destrnik-Trnovska Vas|Divaca|Dobrepolje|Dobrova-Horjul-Polhov Gradec|Dol pri Ljubljani|Domzale|Dornava|Dravograd|Duplek|Gorenja Vas-Poljane|Gorisnica|Gornja Radgona|Gornji Grad|Gornji Petrovci|Grosuplje|Hodos Salovci|Hrastnik|Hrpelje-Kozina|Idrija|Ig|Ilirska Bistrica|Ivancna Gorica|Izola|Jesenice|Jursinci|Kamnik|Kanal|Kidricevo|Kobarid|Kobilje|Kocevje|Komen|Koper|Kozje|Kranj|Kranjska Gora|Krsko|Kungota|Kuzma|Lasko|Lenart|Lendava|Litija|Ljubljana|Ljubno|Ljutomer|Logatec|Loska Dolina|Loski Potok|Luce|Lukovica|Majsperk|Maribor|Medvode|Menges|Metlika|Mezica|Miren-Kostanjevica|Mislinja|Moravce|Moravske Toplice|Mozirje|Murska Sobota|Muta|Naklo|Nazarje|Nova Gorica|Novo Mesto|Odranci|Ormoz|Osilnica|Pesnica|Piran|Pivka|Podcetrtek|Podvelka-Ribnica|Postojna|Preddvor|Ptuj|Puconci|Race-Fram|Radece|Radenci|Radlje ob Dravi|Radovljica|Ravne-Prevalje|Ribnica|Rogasevci|Rogaska Slatina|Rogatec|Ruse|Semic|Sencur|Sentilj|Sentjernej|Sentjur pri Celju|Sevnica|Sezana|Skocjan|Skofja Loka|Skofljica|Slovenj Gradec|Slovenska Bistrica|Slovenske Konjice|Smarje pri Jelsah|Smartno ob Paki|Sostanj|Starse|Store|Sveti Jurij|Tolmin|Trbovlje|Trebnje|Trzic|Turnisce|Velenje|Velike Lasce|Videm|Vipava|Vitanje|Vodice|Vojnik|Vrhnika|Vuzenica|Zagorje ob Savi|Zalec|Zavrc|Zelezniki|Ziri|Zrece";
//Solomon Islands
s_a[Solomon_Islands]="Bellona|Central|Choiseul (Lauru)|Guadalcanal|Honiara|Isabel|Makira|Malaita|Rennell|Temotu|Western";
//Somalia
s_a[Somalia]="Awdal|Bakool|Banaadir|Bari|Bay|Galguduud|Gedo|Hiiraan|Jubbada Dhexe|Jubbada Hoose|Mudug|Nugaal|Sanaag|Shabeellaha Dhexe|Shabeellaha Hoose|Sool|Togdheer|Woqooyi Galbeed";
//South Africa
s_a[South_Africa]="Eastern Cape|Free State|Gauteng|KwaZulu-Natal|Mpumalanga|North-West|Northern Cape|Northern Province|Western Cape";
//South Georgia and South Sandwich Islands
s_a[South_Georgia_and_The_South_Sandwich_Islands]="Bird Island|Bristol Island|Clerke Rocks|Montagu Island|Saunders Island|South Georgia|Southern Thule|Traversay Islands";
//intSouth_Sudan
s_a[South_Sudan]="South Sudan";
//Spain
s_a[Spain]="Andalucia|Aragon|Asturias|Baleares (Balearic Islands)|Canarias (Canary Islands)|Cantabria|Castilla y Leon|Castilla-La Mancha|Cataluna|Ceuta|Communidad Valencian|Extremadura|Galicia|Islas Chafarinas|La Rioja|Madrid|Melilla|Murcia|Navarra|Pais Vasco (Basque Country)|Penon de Alhucemas|Penon de Velez de la Gomera";
//Sri Lanka
s_a[Sri_Lanka]="Central|Eastern|North Central|North Eastern|North Western|Northern|Sabaragamuwa|Southern|Uva|Western";
//Sudan
s_a[Sudan]="A'ali an Nil|Al Bahr al Ahmar|Al Buhayrat|Al Jazirah|Al Khartum|Al Qadarif|Al Wahdah|An Nil al Abyad|An Nil al Azraq|Ash Shamaliyah|Bahr al Jabal|Gharb al Istiwa'iyah|Gharb Bahr al Ghazal|Gharb Darfur|Gharb Kurdufan|Janub Darfur|Janub Kurdufan|Junqali|Kassala|Nahr an Nil|Shamal Bahr al Ghazal|Shamal Darfur|Shamal Kurdufan|Sharq al Istiwa'iyah|Sinnar|Warab";
//Suriname
s_a[Suriname]="Brokopondo|Commewijne|Coronie|Marowijne|Nickerie|Para|Paramaribo|Saramacca|Sipaliwini|Wanica";
//Svalbard
s_a[Svalbard_and_Jan_Mayen]="Barentsoya|Bjornoya|Edgeoya|Hopen|Kvitoya|Nordaustandet|Prins Karls Forland|Spitsbergen";
//Swaziland
s_a[Swaziland]="Hhohho|Lubombo|Manzini|Shiselweni";
//Sweden
s_a[Sweden]="Blekinge|Dalarnas|Gavleborgs|Gotlands|Hallands|Jamtlands|Jonkopings|Kalmar|Kronobergs|Norrbottens|Orebro|Ostergotlands|Skane|Sodermanlands|Stockholms|Uppsala|Varmlands|Vasterbottens|Vasternorrlands|Vastmanlands|Vastra Gotalands";
//Switzerland
s_a[Switzerland]="Aargau|Ausser-Rhoden|Basel-Landschaft|Basel-Stadt|Bern|Fribourg|Geneve|Glarus|Graubunden|Inner-Rhoden|Jura|Luzern|Neuchatel|Nidwalden|Obwalden|Sankt Gallen|Schaffhausen|Schwyz|Solothurn|Thurgau|Ticino|Uri|Valais|Vaud|Zug|Zurich";
//Syria
s_a[Syrian_Arab_Republic]="Al Hasakah|Al Ladhiqiyah|Al Qunaytirah|Ar Raqqah|As Suwayda'|Dar'a|Dayr az Zawr|Dimashq|Halab|Hamah|Hims|Idlib|Rif Dimashq|Tartus";
//Taiwan
s_a[Taiwan__Province_of_China]="Chang-hua|Chi-lung|Chia-i|Chung-hsing-hsin-ts'un|Hsin-chu|Hua-lien|I-lan|Kao-hsiung|Miao-li|Nan-t'ou|P'eng-hu|P'ing-tung|T'ai-chung|T'ai-nan|T'ai-pei|T'ai-tung|T'ao-yuan|Yun-lin";
//Tajikistan
s_a[Tajikistan]="Viloyati Khatlon|Viloyati Leninobod|Viloyati Mukhtori Kuhistoni Badakhshon";
//Tanzania
s_a[Tanzania__United_Republic_of]="Arusha|Dar es Salaam|Dodoma|Iringa|Kagera|Kigoma|Kilimanjaro|Lindi|Mara|Mbeya|Morogoro|Mtwara|Mwanza|Pemba North|Pemba South|Pwani|Rukwa|Ruvuma|Shinyanga|Singida|Tabora|Tanga|Zanzibar Central/South|Zanzibar North|Zanzibar Urban/West";
//Thailand
s_a[Thailand]="Amnat Charoen|Ang Thong|Buriram|Chachoengsao|Chai Nat|Chaiyaphum|Chanthaburi|Chiang Mai|Chiang Rai|Chon Buri|Chumphon|Kalasin|Kamphaeng Phet|Kanchanaburi|Khon Kaen|Krabi|Krung Thep Mahanakhon (Bangkok)|Lampang|Lamphun|Loei|Lop Buri|Mae Hong Son|Maha Sarakham|Mukdahan|Nakhon Nayok|Nakhon Pathom|Nakhon Phanom|Nakhon Ratchasima|Nakhon Sawan|Nakhon Si Thammarat|Nan|Narathiwat|Nong Bua Lamphu|Nong Khai|Nonthaburi|Pathum Thani|Pattani|Phangnga|Phatthalung|Phayao|Phetchabun|Phetchaburi|Phichit|Phitsanulok|Phra Nakhon Si Ayutthaya|Phrae|Phuket|Prachin Buri|Prachuap Khiri Khan|Ranong|Ratchaburi|Rayong|Roi Et|Sa Kaeo|Sakon Nakhon|Samut Prakan|Samut Sakhon|Samut Songkhram|Sara Buri|Satun|Sing Buri|Sisaket|Songkhla|Sukhothai|Suphan Buri|Surat Thani|Surin|Tak|Trang|Trat|Ubon Ratchathani|Udon Thani|Uthai Thani|Uttaradit|Yala|Yasothon";
//intTimor-Leste
s_a[Timor_Leste]="Timor-Leste";
//Toga
s_a[Togo]="De La Kara|Des Plateaux|Des Savanes|Du Centre|Maritime";
//Tokelau
s_a[Tokelau]="Atafu|Fakaofo|Nukunonu";
//Tonga
s_a[Tonga]="Ha'apai|Tongatapu|Vava'u";
//Trinidad
s_a[Trinidad_and_Tobago]="Arima|Caroni|Mayaro|Nariva|Port-of-Spain|Saint Andrew|Saint David|Saint George|Saint Patrick|San Fernando|Victoria";
//Tunisia
s_a[Tunisia]="Ariana|Beja|Ben Arous|Bizerte|El Kef|Gabes|Gafsa|Jendouba|Kairouan|Kasserine|Kebili|Mahdia|Medenine|Monastir|Nabeul|Sfax|Sidi Bou Zid|Siliana|Sousse|Tataouine|Tozeur|Tunis|Zaghouan";
//Turkey
s_a[Turkey]="Adana|Adiyaman|Afyon|Agri|Aksaray|Amasya|Ankara|Antalya|Ardahan|Artvin|Aydin|Balikesir|Bartin|Batman|Bayburt|Bilecik|Bingol|Bitlis|Bolu|Burdur|Bursa|Canakkale|Cankiri|Corum|Denizli|Diyarbakir|Duzce|Edirne|Elazig|Erzincan|Erzurum|Eskisehir|Gaziantep|Giresun|Gumushane|Hakkari|Hatay|Icel|Igdir|Isparta|Istanbul|Izmir|Kahramanmaras|Karabuk|Karaman|Kars|Kastamonu|Kayseri|Kilis|Kirikkale|Kirklareli|Kirsehir|Kocaeli|Konya|Kutahya|Malatya|Manisa|Mardin|Mugla|Mus|Nevsehir|Nigde|Ordu|Osmaniye|Rize|Sakarya|Samsun|Sanliurfa|Siirt|Sinop|Sirnak|Sivas|Tekirdag|Tokat|Trabzon|Tunceli|Usak|Van|Yalova|Yozgat|Zonguldak";
//Turkmenistan
s_a[Turkmenistan]="Ahal Welayaty|Balkan Welayaty|Dashhowuz Welayaty|Lebap Welayaty|Mary Welayaty";
//intTurks_and_Caicos_Islands
s_a[Turks_and_Caicos_Islands]="Turks and Caicos Islands";
//Tuvalu
s_a[Tuvalu]="Tuvalu";
//Uganda
s_a[Uganda]="Adjumani|Apac|Arua|Bugiri|Bundibugyo|Bushenyi|Busia|Gulu|Hoima|Iganga|Jinja|Kabale|Kabarole|Kalangala|Kampala|Kamuli|Kapchorwa|Kasese|Katakwi|Kibale|Kiboga|Kisoro|Kitgum|Kotido|Kumi|Lira|Luwero|Masaka|Masindi|Mbale|Mbarara|Moroto|Moyo|Mpigi|Mubende|Mukono|Nakasongola|Nebbi|Ntungamo|Pallisa|Rakai|Rukungiri|Sembabule|Soroti|Tororo";
//Ukraine
s_a[Ukraine]="Avtonomna Respublika Krym (Simferopol')|Cherkas'ka (Cherkasy)|Chernihivs'ka (Chernihiv)|Chernivets'ka (Chernivtsi)|Dnipropetrovs'ka (Dnipropetrovs'k)|Donets'ka (Donets'k)|Ivano-Frankivs'ka (Ivano-Frankivs'k)|Kharkivs'ka (Kharkiv)|Khersons'ka (Kherson)|Khmel'nyts'ka (Khmel'nyts'kyy)|Kirovohrads'ka (Kirovohrad)|Kyyiv|Kyyivs'ka (Kiev)|L'vivs'ka (L'viv)|Luhans'ka (Luhans'k)|Mykolayivs'ka (Mykolayiv)|Odes'ka (Odesa)|Poltavs'ka (Poltava)|Rivnens'ka (Rivne)|Sevastopol'|Sums'ka (Sumy)|Ternopil's'ka (Ternopil')|Vinnyts'ka (Vinnytsya)|Volyns'ka (Luts'k)|Zakarpats'ka (Uzhhorod)|Zaporiz'ka (Zaporizhzhya)|Zhytomyrs'ka (Zhytomyr)";
//United Arab Emirates
s_a[United_Arab_Emirates]="'Ajman|Abu Zaby (Abu Dhabi)|Al Fujayrah|Ash Shariqah (Sharjah)|Dubayy (Dubai)|Ra's al Khaymah|Umm al Qaywayn";
//United Kingdom
s_a[United_Kingdom]="Barking and Dagenham|Barnet|Barnsley|Bath and North East Somerset|Bedfordshire|Bexley|Birmingham|Blackburn with Darwen|Blackpool|Bolton|Bournemouth|Bracknell Forest|Bradford|Brent|Brighton and Hove|Bromley|Buckinghamshire|Bury|Calderdale|Cambridgeshire|Camden|Cheshire|City of Bristol|City of Kingston upon Hull|City of London|Cornwall|Coventry|Croydon|Cumbria|Darlington|Derby|Derbyshire|Devon|Doncaster|Dorset|Dudley|Durham|Ealing|East Riding of Yorkshire|East Sussex|Enfield|Essex|Gateshead|Gloucestershire|Greenwich|Hackney|Halton|Hammersmith and Fulham|Hampshire|Haringey|Harrow|Hartlepool|Havering|Herefordshire|Hertfordshire|Hillingdon|Hounslow|Isle of Wight|Islington|Kensington and Chelsea|Kent|Kingston upon Thames|Kirklees|Knowsley|Lambeth|Lancashire|Leeds|Leicester|Leicestershire|Lewisham|Lincolnshire|Liverpool|Luton|Manchester|Medway|Merton|Middlesbrough|Milton Keynes|Newcastle upon Tyne|Newham|Norfolk|North East Lincolnshire|North Lincolnshire|North Somerset|North Tyneside|North Yorkshire|Northamptonshire|Northumberland|Nottingham|Nottinghamshire|Oldham|Oxfordshire|Peterborough|Plymouth|Poole|Portsmouth|Reading|Redbridge|Redcar and Cleveland|Richmond upon Thames|Rochdale|Rotherham|Rutland|Salford|Sandwell|Sefton|Sheffield|Shropshire|Slough|Solihull|Somerset|South Gloucestershire|South Tyneside|Southampton|Southend-on-Sea|Southwark|St. Helens|Staffordshire|Stockport|Stockton-on-Tees|Stoke-on-Trent|Suffolk|Sunderland|Surrey|Sutton|Swindon|Tameside|Telford and Wrekin|Thurrock|Torbay|Tower Hamlets|Trafford|Wakefield|Walsall|Waltham Forest|Wandsworth|Warrington|Warwickshire|West Berkshire|West Sussex|Westminster|Wigan|Wiltshire|Windsor and Maidenhead|Wirral|Wokingham|Wolverhampton|Worcestershire|York";
//United States
s_a[United_States]="Alabama;AL|Alaska;AK|Arizona;AZ|Arkansas;AR|California;CA|Colorado;CO|Connecticut;CT|Delaware;DE|Dist. of Columbia;DC|Florida;FL|Georgia;GA|Guam;GU|Hawaii;HI|Idaho;ID|Illinois;IL|Indiana;IN|Iowa;IA|Kansas;KS|Kentucky;KY|Louisiana;LA|Maine;ME|Maryland;MD|Marshall Islands;MH|Massachusetts;MA|Michigan;MI|Micronesia;FM|Minnesota;MN|Mississippi;MS|Missouri;MO|Montana;MT|Nebraska;NE|Nevada;NV|New Hampshire;NH|New Jersey;NJ|New Mexico;NM|New York;NY|North Carolina;NC|North Dakota;ND|Northern Marianas;MP|Ohio;OH|Oklahoma;OK|Oregon;OR|Palau;PW|Pennsylvania;PA|Puerto Rico;PR|Rhode Island;RI|South Carolina;SC|South Dakota;SD|Tennessee;TN|Texas;TX|Utah;UT|Vermont;VT|Virginia;VA|Virgin Islands;VI|Washington;WA|West Virginia;WV|Wisconsin;WI|Wyoming;WY";
//intUnited_States_Minor_Outlying_Islands
s_a[United_States_Minor_Outlying_Islands]="United States Minor Outlying Islands";
//Uruguay
s_a[Uruguay]="Artigas|Canelones|Cerro Largo|Colonia|Durazno|Flores|Florida|Lavalleja|Maldonado|Montevideo|Paysandu|Rio Negro|Rivera|Rocha|Salto|San Jose|Soriano|Tacuarembo|Treinta y Tres";

//Uzbekistan
s_a[Uzbekistan]="Andijon Wiloyati|Bukhoro Wiloyati|Farghona Wiloyati|Jizzakh Wiloyati|Khorazm Wiloyati (Urganch)|Namangan Wiloyati|Nawoiy Wiloyati|Qashqadaryo Wiloyati (Qarshi)|Qoraqalpoghiston (Nukus)|Samarqand Wiloyati|Sirdaryo Wiloyati (Guliston)|Surkhondaryo Wiloyati (Termiz)|Toshkent Shahri|Toshkent Wiloyati";
//Vanuatu
s_a[Vanuatu]="Malampa|Penama|Sanma|Shefa|Tafea|Torba";
//Venezuela
s_a[Venezuela__Bolivarian_Republic_of]="Amazonas|Anzoategui|Apure|Aragua|Barinas|Bolivar|Carabobo|Cojedes|Delta Amacuro|Dependencias Federales|Distrito Federal|Falcon|Guarico|Lara|Merida|Miranda|Monagas|Nueva Esparta|Portuguesa|Sucre|Tachira|Trujillo|Vargas|Yaracuy|Zulia";
//Vietnam
s_a[Viet_Nam]="An Giang|Ba Ria-Vung Tau|Bac Giang|Bac Kan|Bac Lieu|Bac Ninh|Ben Tre|Binh Dinh|Binh Duong|Binh Phuoc|Binh Thuan|Ca Mau|Can Tho|Cao Bang|Da Nang|Dac Lak|Dong Nai|Dong Thap|Gia Lai|Ha Giang|Ha Nam|Ha Noi|Ha Tay|Ha Tinh|Hai Duong|Hai Phong|Ho Chi Minh|Hoa Binh|Hung Yen|Khanh Hoa|Kien Giang|Kon Tum|Lai Chau|Lam Dong|Lang Son|Lao Cai|Long An|Nam Dinh|Nghe An|Ninh Binh|Ninh Thuan|Phu Tho|Phu Yen|Quang Binh|Quang Nam|Quang Ngai|Quang Ninh|Quang Tri|Soc Trang|Son La|Tay Ninh|Thai Binh|Thai Nguyen|Thanh Hoa|Thua Thien-Hue|Tien Giang|Tra Vinh|Tuyen Quang|Vinh Long|Vinh Phuc|Yen Bai";
//British Virgin Islands
s_a[Virgin_Islands__British]="Anegada|Jost Van Dyke|Tortola|Virgin Gorda";
//Virgin Islands
s_a[Virgin_Islands__U_S_]="Saint Croix|Saint John|Saint Thomas";
//Wallis and Futuna
s_a[Wallis_and_Futuna]="Alo|Sigave|Wallis";
//Western Sahara
s_a[Western_Sahara]="Western Sahara";
//Yemen
s_a[Yemen]="'Adan|'Ataq|Abyan|Al Bayda'|Al Hudaydah|Al Jawf|Al Mahrah|Al Mahwit|Dhamar|Hadhramawt|Hajjah|Ibb|Lahij|Ma'rib|Sa'dah|San'a'|Ta'izz";
//Zambia
s_a[Zambia]="Central|Copperbelt|Eastern|Luapula|Lusaka|North-Western|Northern|Southern|Western";
//Zimbabwe
s_a[Zimbabwe]="Bulawayo|Harare|ManicalandMashonaland Central|Mashonaland East|Mashonaland West|Masvingo|Matabeleland North|Matabeleland South|Midlands";

function print_country(country_id){
	// given the id of the <select> tag as function argument, it inserts <option> tags
	var option_str = document.getElementById(country_id);
	option_str.length=0;
	option_str.options[0] = new Option("Select Country","");
	option_str.selectedIndex = 0;
	for (var i=0; i<country_arr.length; i++) {
		option_str.options[option_str.length] = new Option(country_arr[i],country_arr[i]);
	}
}

function print_state(state_id, state_index){
   	
	var option_str = document.getElementById(state_id);
	option_str.length=0;	// Fixed by Julian Woods
	option_str.options[0] = new Option("Select State","");
	option_str.selectedIndex = 0;
	var state_arr = s_a[state_index].split("|");
	// check if ; found (alternate state values exist)
	var found = state_arr[0].search(";");
		
	if(found >0) {
	for (var i=0; i<state_arr.length; i++) {
		state_arr[i]= state_arr[i].split(";");
		option_str.options[option_str.length] = new Option(state_arr[i][0],state_arr[i][1]);
	}
	} else {
	for (var i=0; i<state_arr.length; i++) {
		option_str.options[option_str.length] = new Option(state_arr[i],state_arr[i]);
	}
	}
}
