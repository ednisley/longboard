// Longboard Ground Effect Lighting Controller Case
// Ed Nisley KE4ZNU
// Karen Nisley KC2SYU
// October 2012

// Layout options

Layout = "Build1";
					// Overall layout: Fit Show
					// Printing plates: Build1 .. Buildn (see bottom!)
					// Parts: BatteryLayer PCBLayer1 PCBLayer2
					// Shapes: CaseShell PCBEnvelope

ShowGap = 5;		// spacing between parts in Show layout

//-----
// Extrusion parameters must match reality!

ThreadThick = 0.25;
ThreadWidth = 2.0 * ThreadThick;

HoleWindage = 0.2;

//-- Handy stuff

function IntegerMultiple(Size,Unit) = Unit * ceil(Size / Unit);

Protrusion = 0.1;			// make holes end cleanly

inch = 25.4;

Tap10_32 = 0.159 * inch;
Clear10_32 = 0.190 * inch;
Head10_32 = 0.373 * inch;
Head10_32Thick = 0.110 * inch;
Nut10_32Dia = 0.433 * inch;
Nut10_32Thick = 0.130 * inch;
Washer10_32OD = 0.381 * inch;
Washer10_32ID = 0.204 * inch;

//----------------------
// Dimensions

FlangeWidth = IntegerMultiple(5.0,ThreadWidth);
FlangeThick = 2*ThreadThick;

CellWidth = 50.0;						// Lithium-ion cell dimensions
CellLength = 60.0;
CellThick = 6.0;
CellClearance = 1.5;					// on all sides
CellTabClearance = 15.0;				// for connections

CellHoldWidth = 6.0;					// edge to tabs
CellHoldLength = 4*ThreadWidth;

CellCount = 4;						// cells in the battery

BatteryHeight = CellCount*CellThick + 2*CellClearance;
BatteryLength = CellLength + 2*CellClearance;
BatteryWidth = CellWidth + 2*CellClearance;

PCMWidth = 16.0;						// Battery protection module
PCMLength = 51.0;
PCMThick = 4.0;							// at terminal end of cells

PillarOD = Washer10_32OD + 2*1.0;		// screw pillar diameter
PillarOffset = (PillarOD/2) / sqrt(2.0);	// distance to case inside corner

WallThick = 7.5;						// case wall thickness

PinOD = 1.4;							// alignment pin size

CaseInsideLength = BatteryLength + CellTabClearance + PCMThick;
CaseOALength = CaseInsideLength + 2*WallThick;
echo("Box Length outside: ",CaseOALength);
echo("            inside: ",CaseInsideLength);

WiringLength = CaseInsideLength - CellLength - CellHoldLength - PCMThick;	// wiring space at PCM
echo("Wiring length: ",WiringLength);

CaseInsideWidth = BatteryWidth;
CaseOAWidth = CaseInsideWidth + 2*WallThick;
echo("Box Width outside: ",CaseOAWidth);
echo("           inside: ",CaseInsideWidth);
echo("Screw OC length: ",CaseInsideLength + 2*PillarOffset);
echo("          width: ",CaseInsideWidth + 2*PillarOffset);

PCBThick = 2.0;							// PCB thickness
PCBMargin = 3.0;						// clamping margin around PCB edge
PartHeight = 17.0;						// height of components above PCB (mind the switch!)
WiringThick = 5.0;						// wiring below PCB

echo("PCB thickness:",PCBThick);
echo("    clamp margin: ",PCBMargin);
echo("    wiring: ",WiringThick);
echo("    components: ",PartHeight);

PCBLayer1Thick = IntegerMultiple(WiringThick + PCBThick/2,ThreadThick);
PCBLayer2Thick = IntegerMultiple(PartHeight + PCBThick/2,ThreadThick);

echo("Battery compartment height: ",BatteryHeight);
echo("PCB Layer 1 height: ",PCBLayer1Thick);
echo("PCB Layer 2 height: ",PCBLayer2Thick);

PlateThick = 1/16 * inch;				// aluminum mount / armor plates

echo("Total height: ",2*PlateThick + BatteryHeight + PCBLayer1Thick + PCBLayer2Thick);

ChargePlugOD = 11.5;					// battery charger plug
ChargeJackHeightOC = 6.5;				// coaxial jack center pin height from PCB

SwitchLength = 20.0;					// master power switch
SwitchWidth = 13.0;

WheelCableOD = 3.0;						// 3-conductor from wheel rotation sensor

LEDCableWidth = 10.0;					// 6 conductor loose wires to LED strips
LEDCableThick = 2.0;

//----------------------
// Useful routines

module PolyCyl(Dia,Height,ForceSides=0) {			// based on nophead's polyholes

  Sides = (ForceSides != 0) ? ForceSides : (ceil(Dia) + 2);

  FixDia = Dia / cos(180/Sides);

  cylinder(r=(FixDia + HoleWindage)/2,
           h=Height,
	   $fn=Sides);
}

module ShowPegGrid(Space = 10.0,Size = 1.0) {

  Range = floor(50 / Space);

	for (x=[-Range:Range])
	  for (y=[-Range:Range])
		translate([x*Space,y*Space,Size/2])
		  %cube(Size,center=true);

}


//-------------------
// Shapes

module CaseShell(h=1.0) {

  difference() {
	union() {
	  translate([0,0,h/2])
		cube([CaseOALength,CaseOAWidth,h],center=true);

	  for (x=[-1,1])
		for (y=[-1,1])
		  translate([x*(PillarOffset + CaseInsideLength/2),
					y*(PillarOffset + CaseInsideWidth/2),
					h/2])
			cylinder(r=PillarOD/2,h,center=true,$fn=4*6);
	}

	for (x=[-1,1])					// screw holes on corners
	  for (y=[-1,1])
		translate([x*(PillarOffset + CaseInsideLength/2),
				  y*(PillarOffset + CaseInsideWidth/2),
				  -Protrusion])
		  PolyCyl(Clear10_32,(h + 2*Protrusion),8);

	for (x=[-1,1])					// alignment pins in width walls
	  translate([x*(CaseOALength - WallThick)/2,0,-Protrusion])
	  rotate(45)
		  PolyCyl(PinOD,(h + 2*Protrusion));
	for (y=[-1,1])					// alignment pins in length walls
	  translate([0,y*(CaseOAWidth - WallThick)/2,-Protrusion])
	  rotate(45)
		  PolyCyl(PinOD,(h + 2*Protrusion));

  }
}

module BatteryLayer() {

  difference() {
	CaseShell(BatteryHeight);

    translate([0,0,BatteryHeight/2]) {
	  union() {
		translate([-(CaseInsideLength/2 - BatteryLength/2),0,0])
		  cube([BatteryLength,
			   BatteryWidth,
			   BatteryHeight + 2*Protrusion],
			   center=true);
		cube([CaseInsideLength,
			 (BatteryWidth - 2*CellHoldWidth),
			 BatteryHeight + 2*Protrusion],
			 center = true);
		translate([(CaseInsideLength/2 - WiringLength/2),0,0])
		  cube([WiringLength,
				max(BatteryWidth,PCMLength),
				BatteryHeight + 2*Protrusion],
				  center=true);
	  }
	}
  }
}

module PCBEnvelope() {

  union() {
	translate([0,0,WiringThick + PCBThick + PartHeight/2])
	  cube([CaseInsideLength - 2*PCBMargin,
		   CaseInsideWidth - 2*PCBMargin,
		   PartHeight + 2*Protrusion],
		   center=true);

	translate([0,0,WiringThick + PCBThick/2])
	  cube([CaseInsideLength,CaseInsideWidth,PCBThick],center=true);

	translate([0,0,WiringThick/2])
	  cube([CaseInsideLength - 2*PCBMargin,
		   CaseInsideWidth - 2*PCBMargin,
		   WiringThick + 2*Protrusion],
		   center=true);
  }
}

module PCBLayer1() {

  difference() {
	CaseShell(PCBLayer1Thick);
	PCBEnvelope();
  }

}

module PCBLayer2() {

  difference() {
	CaseShell(PCBLayer2Thick);
	translate([0,0,-(WiringThick + PCBThick/2)])
	  PCBEnvelope();
	translate([25,0,(PCBThick/2 + ChargeJackHeightOC)])
	  rotate([90,0,0])
		PolyCyl(ChargePlugOD,CaseOAWidth);
	translate([25,CaseOAWidth/2,PCBLayer2Thick/2])
	  rotate([90,0,0])
		cube([SwitchLength,SwitchWidth,CaseOAWidth],center=true);
	translate([-CaseOALength/2,0,PCBThick/2])
	  rotate([0,-90,0])
		cube([2*WheelCableOD,WheelCableOD,CaseOALength],center=true);
	translate([CaseOALength/2,0,PCBThick/2])
	  rotate([90,0,90])
		cube([LEDCableWidth,2*LEDCableThick,CaseOALength],center=true);
  }

}

module Aluminum() {
  translate([0,0,PlateThick/2])
	cube([1.1*CaseOALength,1.1*CaseOAWidth,PlateThick - Protrusion],center=true);
}

module MouseEars() {
  
  for (x=[-1,1])
	for (y=[-1,1])
	  translate([x*(PillarOffset + CaseInsideLength/2),
				y*(PillarOffset + CaseInsideWidth/2),
				FlangeThick/2])
		difference() {
		  cylinder(r=(PillarOD/2 + FlangeWidth),FlangeThick,center=true,$fn=8*4);
		  translate([0,0,-FlangeThick/2 - Protrusion])
			PolyCyl(Clear10_32,(FlangeThick + 2*Protrusion),8);
		}  
}



//-------------------
// Build things...

ShowPegGrid();

if ("Battery" == Layout)
  Battery();

//if ("CaseShell" == Layout)
//  CaseShell(something here!!!);

if ("BatteryLayer" == Layout)
  BatteryLayer();

if ("PCBEnvelope" == Layout)
  PCBEnvelope();

if ("PCBLayer1" == Layout)
  PCBLayer1();

if ("PCBLayer2" == Layout)
  PCBLayer2();

if ("Fit" == Layout) {
  color("LightBlue") BatteryLayer();
  translate([0,0,BatteryHeight + PlateThick])
	color("Green") PCBLayer1();
  translate([0,0,BatteryHeight + PlateThick + PCBLayer1Thick])
	color("Cyan") PCBLayer2();
}

if ("Show" == Layout) {
  color("LightBlue") BatteryLayer();
  translate([0,0,BatteryHeight + PlateThick + ShowGap])
	color("Green") PCBLayer1();
  translate([0,0,BatteryHeight + PlateThick + PCBLayer1Thick + 2*ShowGap])
	color("Cyan") PCBLayer2();
}

if ("Build1" == Layout)
  rotate(90) {
	BatteryLayer();
	MouseEars();
  }

if ("Build2" == Layout)
  rotate(90) {
	PCBLayer1();
	MouseEars();
  }

if ("Build3" == Layout) {
  translate([0,0,PCBLayer2Thick])
	rotate([0,180,90])
	  PCBLayer2();
  rotate(90) MouseEars();
}

