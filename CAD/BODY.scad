// ==============================================================================
// FILE: ai_pet_body.scad
// DESCRIPTION: 3D printable Body Assembly for an AI Pet
// BASED ON: Hand-drawn sketch inspiration (Rectangular body, "TIME" screen area)
// OPTIMIZATION: FDM 3D printing (supports needed for main opening)
// MATERIALS: PLA/PETG
// SCREWS: M3 (assumes heat-set inserts in bosses for accessories)
// ==============================================================================

// --- GLOBAL PARAMETERS (Adjustable) -------------------------------------------
$fn = 64; // Smoothness of circles/curves

// Component Dimensions (Include tolerance)
tol = 0.3; // General FDM print tolerance

// Raspberry Pi Pico
pico_w = 51 + tol; // PCB length
pico_h = 21 + tol; // PCB width
pico_d = 4;       // Total thickness

// Waveshare E-Ink Display (Example: 2.13 inch variant)
eink_pcb_w = 65 + tol; // Overall PCB Width
eink_pcb_h = 30 + tol; // Overall PCB Height
eink_d = 3;           // Thickness
eink_screen_w = 48;    // Visible screen width
eink_screen_h = 23.5;  // Visible screen height

// MAX98357A I2S Amplifier
amp_w = 20 + tol;
amp_h = 20 + tol;
amp_d = 5;

// General Design Parameters
wall_thickness = 3.0;
corner_radius = 5;
mount_boss_dia = 7; // Standoff diameter for M3 screws
mount_boss_h = 5;   // Standoff height

// --- MAIN ASSEMBLY CALCULATION ------------------------------------------------
// Large, intentionally oversized overall body dimensions
body_w = eink_pcb_w + 50; // Width (horizontal)
body_h = pico_w + 60;     // Height (vertical)
body_d = eink_pcb_h + 80; // Depth (front-to-back)

// --- MAIN EXECUTION -----------------------------------------------------------
// Reoriented so the display side faces the positive X-axis and sits flat on the build plate
translate([body_d, 0, 0]) 
rotate([0, 90, 0]) {
    union() {
        difference() {
            main_body_volume();
            internal_hollow_body();
            front_eink_cutout();
            top_access_panel_cutout(); // Opposite the grill
            usb_port_cutout();
            ventilation_slots();
        }

        // Add internal mounting bosses (not subtracted)
        pico_mount();
        eink_mount();
        amplifier_mount();
    }
}

// ==============================================================================
// MODULE DEFINITIONS
// ==============================================================================

// 1. MAIN BODY VOLUME (Rectangular with slight rounded corners)
module main_body_volume() {
    hull() {
        translate([corner_radius, corner_radius, corner_radius]) 
            sphere(corner_radius);
        translate([body_w - corner_radius, corner_radius, corner_radius]) 
            sphere(corner_radius);
        translate([corner_radius, body_h - corner_radius, corner_radius]) 
            sphere(corner_radius);
        translate([body_w - corner_radius, body_h - corner_radius, corner_radius]) 
            sphere(corner_radius);
        
        translate([corner_radius, corner_radius, body_d - corner_radius]) 
            sphere(corner_radius);
        translate([body_w - corner_radius, corner_radius, body_d - corner_radius]) 
            sphere(corner_radius);
        translate([corner_radius, body_h - corner_radius, body_d - corner_radius]) 
            sphere(corner_radius);
        translate([body_w - corner_radius, body_h - corner_radius, body_d - corner_radius]) 
            sphere(corner_radius);
    }
}

// 2. INTERNAL HOLLOW (Extensive space for large components, battery, wiring)
module internal_hollow_body() {
    translate([wall_thickness, wall_thickness, wall_thickness]) 
        scale([ (body_w - wall_thickness * 2)/body_w, 
                 (body_h - wall_thickness * 2)/body_h, 
                 (body_d - wall_thickness * 2)/body_d ])
        main_body_volume();
}

// 3. FRONT E-INK DISPLAY CUTOUT (Horizontal window)
module front_eink_cutout() {
    translate([body_w/2 - eink_screen_w/2, body_h/2 - eink_screen_h/2, -1]) 
        cube([eink_screen_w, eink_screen_h, wall_thickness + 2]);
}

// 4. TOP ACCESS PANEL CUTOUT (Removable panel opposite the ventilation grill)
module top_access_panel_cutout() {
    // Increased lip from 10 to 15 to make the cutout slightly smaller
    lip = 15;
    translate([lip, body_h - wall_thickness - 1, lip])
        cube([body_w - lip*2, wall_thickness + 2, body_d - lip*2]);
}

// 5. USB PORT CUTOUT (Side panel)
module usb_port_cutout() {
    translate([-1, wall_thickness + pico_w/2 + 5, wall_thickness + pico_d + mount_boss_h + 2])
        cube([wall_thickness + 2, 10, 6]); // Standard USB-C connector size
}

// 6. VENTILATION SLOTS (Bottom surface)
module ventilation_slots() {
    grid_size = 5;
    slot_w = 1.5;
    num_slots = floor((body_w - wall_thickness * 4) / grid_size);
    
    for (i = [0 : num_slots - 1]) {
        translate([wall_thickness * 2 + i * grid_size, -1, wall_thickness * 2]) 
            cube([slot_w, 30, body_d/2]);
    }
}

// --- INTERNAL COMPONENT MOUNTS ------------------------------------------------

// PICO MOUNT (Rear wall, vertical orientation)
module pico_mount() {
    hole_pattern_w = 48.26; // Distance between outer mount holes
    hole_pattern_h = 17.78;
    
    // FIXED: Changed pico_h to pico_w so the mount doesn't clip through the outer X wall
    pico_x = body_w - wall_thickness - pico_w - 10;
    pico_y = wall_thickness + 10;
    
    translate([pico_x, pico_y, wall_thickness]) {
        // Boss 1
        translate([0, 0, 0]) cylinder(d=mount_boss_dia, h=mount_boss_h);
        // Boss 2
        translate([hole_pattern_w, 0, 0]) cylinder(d=mount_boss_dia, h=mount_boss_h);
        // Boss 3
        translate([0, hole_pattern_h, 0]) cylinder(d=mount_boss_dia, h=mount_boss_h);
        // Boss 4
        translate([hole_pattern_w, hole_pattern_h, 0]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    }
}

// E-INK MOUNT (Behind front wall)
module eink_mount() {
    eink_x = body_w/2 - eink_pcb_w/2;
    eink_y = body_h/2 - eink_pcb_h/2;
    
    // Four corner bosses
    translate([eink_x + 2, eink_y + 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    translate([eink_x + eink_pcb_w - 2, eink_y + 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    translate([eink_x + 2, eink_y + eink_pcb_h - 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    translate([eink_x + eink_pcb_w - 2, eink_y + eink_pcb_h - 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
}

// AMPLIFIER MOUNT (Inside base, rear-right)
module amplifier_mount() {
    amp_x = body_w - amp_w - 15;
    amp_y = body_h - amp_h - 15;
    
    // Four corner bosses
    translate([amp_x + 2, amp_y + 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    translate([amp_x + amp_w - 2, amp_y + 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    translate([amp_x + 2, amp_y + amp_h - 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
    translate([amp_x + amp_w - 2, amp_y + amp_h - 2, wall_thickness]) cylinder(d=mount_boss_dia, h=mount_boss_h);
}