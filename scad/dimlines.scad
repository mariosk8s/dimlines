/* Dimension lines for OpenSCAD.
 *
 * Copyright 2013-2016 Don Smiley
 *
 * SPDX-License-Identifier: MIT
 *
 * What this program does:
 *
 * This program can draw lines with arrows and has a primitive dimensioning
 * element for putting text within arrows.  In addition, should the area being
 * dimensioned be too narrow, there is a provision for putting the text on
 * either side of the arrows.
 *
 * The dimension lines are drawn on the xy plane and are meant to be seen in a
 * top view.
 *
 * =======================================================
 * Be sure to view this from above -- ctrl-4
 * =======================================================
 *
 * To use this program, copy this file into your OpenSCAD project or library
 * directory and add "use <dimlines.scad>" to your OpenSCAD files. You may
 * optionally modify the size constants DIM_FONTSIZE, DIM_LINE_WIDTH and
 * DIM_HOLE_CENTER to match the size of your model.
 *
 * Available:
 *
 * Assorted constants to ease the use of dimensioning line.  Because there is
 * no introspection regarding the dimensions of your creations, you will want
 * to adjust the parameters to fit the context of your creation.  You can adjust
 * the size of the text, lines, etc to match the rest of your objects.
 *
 * the following functions or modules are available.
 *
 *  line(length, width, height=DIM_HEIGHT, left_arrow=false, right_arrow=false)
 *      Can draw a line with the options of including an arrow at either end
 *
 *  circle_center(radius, size, line_width)
 *      Draws the cross in the center of a circle.  There are defaults for the
 *      cross size and line width
 *
 *  dimensions(length, line_width, loc=DIM_CENTER, mytext="")
 *      draws text within lines, such as <--- 3.5 --->
 *      with the use of the variable loc you can alter the placement of the text
 *      loc=DIM_CENTER      <--- 3.5 --->  this is the default
 *      loc=DIM_LEFT        3.5 <---->
 *      loc=DIM_RIGHT       <----> 3.5
 *      loc=DIM_OUTSIDE     ---> 3.5 <---
 *
 *      Can also pass in text such as a variable name in place of a
 *      numeric dimension.
 *
 *  leader_line(angle, radius, angle_length, horz_line_length,
 *              direction=DIM_RIGHT, line_width, text)
 *
 *      for use in pointing to the edge of a circle and showing text
 *
 *      usage of the leader line:
 *          translate to the center of the circle
 *      Typically leader lines have a bend in them.  The angle variable is used
 *      to specify the angle from which the line will point to the center of the
 *      circle.  The radius specifies the location of the arrow. The
 *      angle_length is distance that the leader line takes until meeting the
 *      horizontal line. Once the angled line meets the horizontal line, that
 *      line will either extend to the right or left.  direction and therefore
 *      be either DIM_RIGHT or DIM_LEFT.  line_width typically would be whatever
 *      constant you have selected for all your dimensioned lines. Finally, the
 *      text will be the value that you wish to show, such as R 0.500.
 *
 *
 * Created by Don Smiley
 *
 */


//  these variables are used within the modules
DIM_CENTER = 0;
DIM_LEFT = 1;
DIM_RIGHT = 2;
DIM_OUTSIDE = 3;
DIM_HORZ = 0;
DIM_VERT = 1;
DIM_UPPER_LEFT = 0;
DIM_UPPER_RIGHT = 1;
DIM_LOWER_LEFT = 2;
DIM_LOWER_RIGHT = 3;

/* Constants related to the annotation lines
 *
 * Because the dimension of the part to be documented can vary widely, you
 * probably are going to need to adjust the parameters to fit the context of
 * your part.
 *
 * DIM_FONTSIZE is the approximate hight of a single line of text. By default,
 * all of the other sizes, like line width and arrow head size, are calculated
 * relative to the font size. You can change DIM_FONTSIZE to a text height
 * appropriate for your model, and all the other dimensions will be adjusted
 * accordingly.
 *
 * For example, the following parameters were used for a part 3.5 units long.
 * DIM_FONTSIZE is set to about 5% of the object length, or 0.175 units. In
 * addition, DIM_HEIGHT is a height meant to be slightly above your tallest
 * part.
 */

DIM_FONTSIZE = 0.175;

// an approximation that sets the line widths relative to the font size
DIM_LINE_WIDTH = DIM_FONTSIZE / 7; // width of dimension lines
DIM_HEIGHT = .01; // height of lines

// refers to the size of the cross within a circle
DIM_HOLE_CENTER = DIM_LINE_WIDTH * 6;


module arrow(arr_points, arr_length, height) {
    // arrow points to the left
    linear_extrude(height=height, convexity=2)

    polygon(
        points = [[0, 0],
                [arr_points, arr_points / 2],
                [arr_length, 0],
                [arr_points, -arr_points / 2]],
        paths = [[0, 1, 2, 3]], convexity = 2);
}

module line(length, width=DIM_LINE_WIDTH,
            height=DIM_HEIGHT,
            left_arrow=false,
            right_arrow=false
            ) {
    /* This module draws a line that can have an arrow on either end.  Because
     * the intended use is to be viewed strictly from above, the height of the
     * line is set arbitrarily thin.
     *
     * The factors arr_length and arr_points are used to create a proportionate
     * arrow. Your sense of asthetics may lead you to choose different
     * numbers.
     */

    arr_points = width * 4;
    arr_length = arr_points * .6;
    line_length = length - arr_length * ((left_arrow ? 1 : 0) + (right_arrow ? 1 : 0));

    union() {
        translate([left_arrow ? arr_length : 0, -width / 2, 0])
            cube([line_length, width, height], center=false);

        if (left_arrow)
            arrow(arr_points, arr_length, height);

        if (right_arrow) {
            translate([length, 0, 0])
            rotate([0, 0, 180])
            arrow(arr_points, arr_length, height);
        }
    }
}


module circle_center(radius, size=DIM_HOLE_CENTER, line_width=DIM_LINE_WIDTH)
{
    translate([-size / 2, 0, 0])
        line(length=size, width=line_width);

    translate([radius - size / 2, 0, 0])
        line(length=size, width=line_width);

    translate([-radius - size / 2, 0, 0])
        line(length=size, width=line_width);

    translate([0, -size / 2, 0]) rotate([0, 0, 90])
        line(length=size, width=line_width);

    translate([0, radius - size / 2, 0]) rotate([0, 0, 90])
        line(length=size, width=line_width);

    translate([0, -radius - size / 2, 0]) rotate([0, 0, 90])
        line(length=size, width=line_width);
}

function text_or_length(length, mytext) = (len(mytext) == 0)
    ? str(length): mytext;

/**
 * dim_text() - Add text label scaled to match size of dimension lines.
 *
 * Modifier for standard text() module. Performs two modification:
 * - Scales text to match size of dimension lines.
 * - Extrudes text into a 3D object so that dimensions don't mix 2D and 3D objects
 *
 * To use this modifier, place it immediately before a text() call.
 */
module scale_text()
{
    linear_extrude(DIM_HEIGHT, convexity=10)
        scale([DIM_FONTSIZE/10, DIM_FONTSIZE/10])
            children();
}

module dimensions(length, line_width=DIM_LINE_WIDTH, loc=DIM_CENTER,
                  mytext="") {

    space = len(text_or_length(length, mytext)) * DIM_FONTSIZE;

    if (loc == DIM_CENTER) {
        line(length=length / 2 - space / 2, width=line_width, left_arrow=true);
        translate([(length) / 2, 0]) scale_text()
            text(text_or_length(length, mytext), halign="center", valign="center");

        translate([length / 2 + space / 2, 0, 0])
        line(length=length / 2 - space / 2, width=line_width, right_arrow=true);
    } else {

        if (loc == DIM_LEFT) {
            line(length=length, width=line_width,
                 left_arrow=true, right_arrow=true);

            translate([-DIM_FONTSIZE, 0]) scale_text()
                text(text_or_length(length, mytext), halign="right", valign="center");
        } else {
            if (loc == DIM_RIGHT) {
                line(length=length, width=line_width,
                     left_arrow=true, right_arrow=true);

                translate([length+DIM_FONTSIZE, 0]) scale_text()
                    text(text_or_length(length, mytext), valign="center");
            } else {
                if (loc == DIM_OUTSIDE) {

                    rotate([0, 180, 0])
                    line(length=length / 2, width=line_width,
                         left_arrow=true, right_arrow=false);

                    translate([(length) / 2, 0]) scale_text()
                        text(text_or_length(length, mytext), halign="center", valign="center");

                    translate([length, 0, 0])
                    line(length=length / 2, width=line_width,
                         left_arrow=true, right_arrow=false);
                }
            }
        }
    }
}

module leader_line(angle, radius, angle_length, horz_line_length,
        direction=DIM_RIGHT, line_width=DIM_LINE_WIDTH, text, do_circle=false) {
    /* leader_line
     *
     * Creates a line that points directly at a center point from the given
     * radius.
     * Then, a short horzizontal line is generated, followed by text.  The
     * direction of the horizontal short line defaults to the right, the
     * choice made by either DIM_RIGHT or DIM_LEFT
     */

    text_length = len(text) * DIM_FONTSIZE * 0.6;
    space = DIM_FONTSIZE * 0.6;

    rotate([0, 0, angle])
    translate([radius, 0, 0])
    line(length=angle_length, width=line_width, left_arrow=true);

    rotate([0, 0, angle])
    translate([radius + angle_length, 0, 0])
    rotate([0, 0, -angle])
    union() {
        if (direction == DIM_RIGHT) {
            line(length=horz_line_length, width=line_width);

            // Using centered text so that the 'do_circle' feature looks correct
            translate([horz_line_length + space + text_length/2, 0]) scale_text()
                text(text, valign="center", halign="center");

            if (do_circle) {
                translate([(horz_line_length + space + text_length/2),
                          0,  0])
                difference() {
                    cylinder(h=DIM_HEIGHT, r=text_length + space - line_width,
                            center=true, $fn=100);
                    cylinder(h=.05, r=text_length + space - line_width * 2,
                            center=true, $fn=100);
                }
            }

        } else {
            translate([-horz_line_length, 0, 0])
            line(length=horz_line_length, width=line_width);

            translate([-(horz_line_length + space), 0]) scale_text()
                text(text, halign="right", valign="center");

        }
    }
}

module titleblock(lines, descs, details) {
    /* titleblock
     *
     * This module accepts the following arrays with formats:
     *
     * holds the description of the lines. width is a factor that
     * expands the line width beyond DIM_LINE_WIDTH
     *
     * lines     = [[startx, starty, horz/vert, length, width],
     *              [startx, starty, horz/vert, length, width]]
     *
     * holds the descriptions of the title blocks. these are meant to sit in
     * the upper left corner. size, like width above, is a factor that
     * increases/decreases the size of the font
     *
     * descs    = [[startx, starty, horz/vert, text, size],
     *             [startx, starty, horz/vert, text, size]]
     *
     * holds the detail associated with the part being documented
     *
     * details    = [[startx, starty, horz/vert, text, size],
     *               [startx, starty, horz/vert, text, size]]
    */

    for (line = lines) {
        translate([line[0] * DIM_LINE_WIDTH,
                    line[1] * DIM_LINE_WIDTH,
                    0])
        if (line[2] == DIM_VERT) {
            rotate([0, 0, -90])
            line(length=line[3] * DIM_LINE_WIDTH, width=DIM_LINE_WIDTH * line[4]);
        } else {
            line(length=(line[3] + 1) * DIM_LINE_WIDTH, width=DIM_LINE_WIDTH * line[4]);
        }

    }

    for (line = descs) {
        translate([line[0] * DIM_LINE_WIDTH, line[1] * DIM_LINE_WIDTH, 0])
        if (line[2] == DIM_VERT) {
            rotate([0, 0, 90]) scale_text()
                text(line[3], size=10*line[4]);
        } else {
            scale_text() text(line[3], size=10*line[4]);
        }
    }

    for (line = details) {
        translate([line[0] * DIM_LINE_WIDTH, line[1] * DIM_LINE_WIDTH, 0])
        if (line[2] == DIM_VERT) {
            rotate([0, 0, 90])
            scale_text() text(line[3], size=10*line[4]);
        } else {
            scale_text() text(line[3], size=10*line[4]);
        }
    }

}

/* Scale examples to match size of dimension elements */
DIM_SAMPLE_SCALE = DIM_FONTSIZE / 0.175;

module sample_titleblock1() {
    /* sample titleblock
     *
     * Note the use of double thickness lines around the perimeter. Any line
     * can be adjusted to be thinner or thicker.
     *
     * Note also that since lines are centered on their widths, some adjustments
     * for half-width spacing is needed to avoid a jagged look on corners.
     * You can see that in the horizontal lines in the first section that are
     * offset by 1, which is the half-width of the outside line.
     */
    title_width = 290;
    row_height = 15;

    cols = [-1, 50, 114, 200, 215, 260];
    rows = [0, -row_height, -row_height * 2, -row_height * 3, -row_height * 4];

    // spacing tweaks to fit into the blocks
    desc_x = 2; // column offset for start of small text
    desc_y = -5; // row offset for start of small text
    det_y = -12;  // row offset for start of detail text
    desc_size = .75; // relative size of description text

    lines = [
        // horizontal lines
        [cols[0], rows[0], DIM_HORZ, title_width, 2],
        [cols[0], rows[1], DIM_HORZ, title_width, 1],
        [cols[2], rows[2], DIM_HORZ, title_width - cols[2] - 1, 1],
        [cols[3], rows[3], DIM_HORZ, title_width - cols[3] - 1, 1],
        [cols[0], rows[4] - 1, DIM_HORZ, title_width, 2],

        // vertical lines
        [0, 0, DIM_VERT, row_height * 4, 2],
        [cols[1], rows[0], DIM_VERT, row_height, 1],
        [cols[2], rows[0], DIM_VERT, row_height * 4, 1],
        [cols[3], rows[0], DIM_VERT, row_height * 4, 1],
        [cols[4], rows[3], DIM_VERT, row_height, 1],
        [cols[5], rows[3], DIM_VERT, row_height, 1],
        [title_width - 1, 0, DIM_VERT, row_height * 4, 2],
    ];

    descs = [
        [cols[0] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Responsible dep", desc_size],
        [cols[1] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Technical reference", desc_size],
        [cols[2] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Creator", desc_size],
        [cols[3] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Approval person", desc_size],
        [cols[2] + desc_x, rows[1] + desc_y, DIM_HORZ,
            "Document type", desc_size],
        [cols[3] + desc_x, rows[1] + desc_y, DIM_HORZ,
            "Document status", desc_size],
        [cols[2] + desc_x, rows[2] + desc_y, DIM_HORZ,
            "Title", desc_size],
        [cols[3] + desc_x, rows[2] + desc_y, DIM_HORZ,
            "Identification number", desc_size],
        [cols[3] + desc_x, rows[3] + desc_y, DIM_HORZ,
            "Rev", desc_size],
        [cols[4] + desc_x, rows[3] + desc_y, DIM_HORZ,
            "Date of issue", desc_size],
        [cols[5] + desc_x, rows[3] + desc_y, DIM_HORZ,
            "Sheet", desc_size]
    ];

    details = [
        [cols[0] + desc_x,  rows[0] + det_y, DIM_HORZ,
            " ", 1], //Responsible dep.
        [cols[1] + desc_x, rows[0] + det_y, DIM_HORZ,
            " ", 1], //Technical reference
        [cols[2] + desc_x, rows[0] + det_y, DIM_HORZ,
            "D. Smiley ", 1], //Creator
        [cols[3] + desc_x, rows[0] + det_y, DIM_HORZ,
            " ", 1], //Approval person
        [cols[0] + desc_x + 10, rows[2] + det_y, DIM_HORZ,
            "My OpenSCAD Project", 1],
        [cols[2] + desc_x, rows[1] + det_y, DIM_HORZ,
            " ", 1], //Document type
        [cols[3] + desc_x, rows[1] + det_y, DIM_HORZ,
            "First issue", 1], //Document status
        [cols[2] + desc_x, rows[2] + det_y, DIM_HORZ,
            "Sample Part", 1], //Title
        [cols[3] + desc_x, rows[2] + det_y, DIM_HORZ,
            "123", 1], //Identification number
        [cols[3] + desc_x, rows[3] + det_y, DIM_HORZ,
            " ", 1], //Rev
        [cols[4] + desc_x, rows[3] + det_y, DIM_HORZ,
            "2013-3-31", 1], //Date of issue
        [cols[5] + desc_x, rows[3] + det_y, DIM_HORZ,
            "1/100", 1] //Sheet
    ];


    titleblock(lines, descs, details);
}

module sample_revisionblock(revisions) {

    // revision block headings
    row_height = 15;
    revision_width = 100;
    desc_x = 2;
    desc_y = -10;
    desc_size = 1;

    cols = [0, 20, 60, revision_width];
    rows = [0, -row_height, -row_height * 2];

    // draw
    lines = [
        // horizontal lines
        [cols[0], rows[0], DIM_HORZ, revision_width, 1],
        [cols[0], rows[1], DIM_HORZ, revision_width, 1],
        [cols[0], rows[2], DIM_HORZ, revision_width, 1],

        // vertical lines
        [cols[0], rows[0], DIM_VERT, row_height * 2, 1],
        [cols[1], rows[0], DIM_VERT, row_height, 1],
        [cols[2], rows[0], DIM_VERT, row_height, 1],
        [cols[3], rows[0], DIM_VERT, row_height * 2, 1],
    ];

    descs = [
        [cols[0] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Rev.", desc_size],
        [cols[1] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Date", desc_size],
        [cols[2] + desc_x, rows[0] + desc_y, DIM_HORZ,
            "Initials", desc_size],
        [cols[1] + desc_x, rows[1] + desc_y, DIM_HORZ,
            "Revisions", desc_size],
    ];

    details = [];
    num_revisions = len(revisions);

    translate([-(revision_width + 40) * DIM_LINE_WIDTH,
              row_height * 2 * DIM_LINE_WIDTH, 0])
    union() {
        titleblock(lines, descs, details);

        //  now for the start of actual revisions
        //  do this piecemeal -- draw the vertical first

        for (col = [0: len(cols)]) {
            translate([cols[col] * DIM_LINE_WIDTH, 0, 0])
            rotate([0, 0, 90])
            line(num_revisions * row_height * DIM_LINE_WIDTH);
        }

        for (row = [0: len(revisions)]) {
            translate([0, row * row_height * DIM_LINE_WIDTH, 0])
            line(revision_width * DIM_LINE_WIDTH);

            for (col = [0:2]) {
                translate([(cols[col] + desc_x) * DIM_LINE_WIDTH,
                    ((row + 1) * row_height + desc_y) * DIM_LINE_WIDTH, 0])
                scale_text() text(revisions[row][col]);
            }
        }

    }
}

module sample_titleblock2() {

    row_height = 20;

    cols = [-.5, 100, 154, 270];
    title_width = cols[3];

    rows = [0, -row_height, -row_height * 2, -row_height * 3, -row_height * 4,
            -row_height * 5, -row_height * 6, -row_height * 7
    ];

    // spacing tweaks to fit into the blocks
    desc_x = 2; // column offset for start of small text
    desc_y = -5; // row offset for start of small text
    det_x = 15;  // col offset for start of detail text
    det_y = -15;  // row offset for start of detail text
    desc_size = .75; // relative size of description text


    lines = [
        // horizontal lines
        [-.5, 0, DIM_HORZ, title_width, 1],

        [cols[2], rows[1], DIM_HORZ, cols[3] - cols[2] - .5, 1],
        [cols[0], rows[2], DIM_HORZ, cols[1] - cols[0] - .5, 1],
        [cols[0], rows[3], DIM_HORZ, cols[3] - .5, 1],
        [cols[0], rows[4], DIM_HORZ, cols[2] - .5, 1],
        [cols[0], rows[5], DIM_HORZ, cols[3] - .5, 1],
        [cols[0], rows[6], DIM_HORZ, cols[2] - .5, 1],
        [cols[0], rows[7], DIM_HORZ, cols[2] - .5, 1],

        [cols[0], rows[7], DIM_HORZ, title_width, 1],

        // vertical lines
        [cols[0], rows[0], DIM_VERT, -rows[7], 1],
        [cols[1], rows[0], DIM_VERT, -rows[7], 1],
        [cols[2], rows[0], DIM_VERT, -rows[7], 1],
        [cols[3], rows[0], DIM_VERT, -rows[7], 1],
    ];

    part_desc = ["Material", "Finish", "Weight", "Part No."];
    doc_desc = ["Drawing Number",
                    "Created by",
                    "Reviewed by",
                    "Date of issue"
    ];

    // aspects of the part
    part_details = [
        "My Sample Part",   // title
        "Stainless Steel",  // material
        " ",                // finish
        "2.5",              // weight
        "123",              // part no
    ];

    // aspects documenting the creation of the part
    doc_details = [
        "33-2",             // Drawing No.
        "D. Smiley",        // Created by
        " ",                // Reviewd by
        "2013-3-31",        // Date
    ];

    // the organization making the part
    org_details = [
        "My logo",
        "Canny Machines",
        "Org Address, phone"
    ];

    descs = [

        // part description
        [cols[0] + desc_x, rows[2] + desc_y, DIM_HORZ, part_desc[0], desc_size],
        [cols[0] + desc_x, rows[3] + desc_y, DIM_HORZ, part_desc[1], desc_size],
        [cols[0] + desc_x, rows[4] + desc_y, DIM_HORZ, part_desc[2], desc_size],
        [cols[0] + desc_x, rows[5] + desc_y, DIM_HORZ, part_desc[3], desc_size],

        // documentation description
        [cols[1] + desc_x, rows[3] + desc_y, DIM_HORZ, doc_desc[0], desc_size],
        [cols[1] + desc_x, rows[4] + desc_y, DIM_HORZ, doc_desc[1], desc_size],
        [cols[1] + desc_x, rows[5] + desc_y, DIM_HORZ, doc_desc[2], desc_size],
        [cols[1] + desc_x, rows[6] + desc_y, DIM_HORZ, doc_desc[3], desc_size],
   ];

    details = [
        [cols[0] + desc_x, rows[0] + det_y, DIM_HORZ, part_details[0], 1.5],
        [cols[0] + desc_x, rows[2] + det_y, DIM_HORZ, part_details[1], 1],
        [cols[0] + desc_x, rows[3] + det_y, DIM_HORZ, part_details[2], 1],
        [cols[0] + desc_x, rows[4] + det_y, DIM_HORZ, part_details[3], 1],
        [cols[0] + desc_x, rows[5] + det_y, DIM_HORZ, part_details[4], 1],

        [cols[1] + desc_x * 2, rows[3] + det_y, DIM_HORZ, doc_details[0], 1],
        [cols[1] + desc_x * 2, rows[4] + det_y, DIM_HORZ, doc_details[1], 1],
        [cols[1] + desc_x * 2, rows[5] + det_y, DIM_HORZ, doc_details[2], 1],
        [cols[1] + desc_x * 2, rows[6] + det_y, DIM_HORZ, doc_details[3], 1],

        // Organization Details
        [cols[1] + desc_x, rows[1] + det_y, DIM_HORZ, org_details[0], 1.5],
        [cols[2] + desc_x, rows[0] + det_y, DIM_HORZ, org_details[1], 1.5],
        [cols[2] + desc_x, rows[1] + det_y, DIM_HORZ, org_details[2], 1],

    ];

    titleblock(lines, descs, details);

    revisions = [
        ["1a", "2013-4-1", "ds"],
        ["1b", "2013-4-2", "ds"],
        ["2a", "2013-4-3", "ds"],
        ["3a", "2013-4-5", "ds"],
        ["4a", "2013-4-15", "ds"],
    ];

    rotate([0, 0, 90])
    sample_revisionblock(revisions);


}

module sample_lines()
{
    // sample lines
    line(length=2 * DIM_SAMPLE_SCALE, left_arrow=false, right_arrow=false);
    translate([0, -0.25 * DIM_SAMPLE_SCALE, 0])
        line(length=2 * DIM_SAMPLE_SCALE, left_arrow=true, right_arrow=false);
    translate([0, -0.5 * DIM_SAMPLE_SCALE, 0])
        line(length=2 * DIM_SAMPLE_SCALE, left_arrow=false, right_arrow=true);
    translate([0, -0.75 * DIM_SAMPLE_SCALE, 0])
        line(length=2 * DIM_SAMPLE_SCALE, left_arrow=true, right_arrow=true);
}

module sample_dimensions()
{
    /* shows all possibilities
        DIM_CENTER = 0;
        DIM_LEFT = 1;
        DIM_RIGHT = 2;
        DIM_OUTSIDE = 3;
    */

    length = 2.5 * DIM_SAMPLE_SCALE;

    // The following two lines are vertical lines that bracket the dimensions
    // left arrow
    translate([0, -1.75 * DIM_SAMPLE_SCALE, 0]) rotate([0, 0, 90])
        line(length);

    // right arrow
    translate([length, -1.75 * DIM_SAMPLE_SCALE, 0]) rotate([0, 0, 90])
        line(length);

    //  The following runs through all the dimension types
    for (i = [0:4]) {
        translate([0, -.5 * i * DIM_SAMPLE_SCALE, 0])
        dimensions(length=length, loc=i);
    }
}


module sample_dimensions_with_text(mytext) {

    /* shows all possibilities
        DIM_CENTER = 0;
        DIM_LEFT = 1;
        DIM_RIGHT = 2;
        DIM_OUTSIDE = 3;

        This shows sample dimensions with custom text inserted instead of
        lengths. This enables variable names to be passed in to drawings.
    */

    length = 2.5 * DIM_SAMPLE_SCALE;

    // The following two lines are vertical lines that bracket the dimensions
    // left arrow
    translate([0, -1.75 * DIM_SAMPLE_SCALE, 0]) rotate([0, 0, 90])
        line(length);

    // right arrow
    translate([length, -1.75 * DIM_SAMPLE_SCALE, 0]) rotate([0, 0, 90])
        line(length=length);

    //  The following runs through all the dimension types
    for (i = [0:4]) {
        translate([0, -.5 * i * DIM_SAMPLE_SCALE, 0])
        dimensions(length=length, loc=i, mytext=mytext);
    }
}


module sample_leaderlines() {

    radius = .25 * DIM_SAMPLE_SCALE;
    for (i = [0:6]) {
        leader_line(angle=i * 15, radius=.25 * DIM_SAMPLE_SCALE,
                    angle_length=(i * .25 * DIM_SAMPLE_SCALE),
                    horz_line_length=.5 * DIM_SAMPLE_SCALE, direction=DIM_RIGHT,
                    text=str("leader line angle: ", i * 15 + 90),
                    do_circle=false
                   );
    }

    for (i = [1:7]) {
        leader_line(angle=i * 20 + 90, radius=.25 * DIM_SAMPLE_SCALE,
                    angle_length=.75 * DIM_SAMPLE_SCALE,
                    horz_line_length=.5 * DIM_SAMPLE_SCALE, direction=DIM_LEFT,
                    text=str("leader line angle: ", i * 20 + 90));
    }
    for (i = [1:4]) {
        leader_line(angle=-i * 20, radius=.25 * DIM_SAMPLE_SCALE,
                    angle_length=1.5 * DIM_SAMPLE_SCALE,
                    horz_line_length=.25 * DIM_SAMPLE_SCALE, direction=DIM_RIGHT,
                    text=str(i),
                    do_circle=true
                   );
    }
 }

module sample_circlecenter() {

    radius = .25 * DIM_SAMPLE_SCALE;
    difference() {
        cube([DIM_SAMPLE_SCALE, DIM_SAMPLE_SCALE, DIM_SAMPLE_SCALE], center=true);
        cylinder(h=1.1 * DIM_SAMPLE_SCALE, r=radius, center=true, $fn=100);
    }
    color("Black") translate([0, 0, .51 * DIM_SAMPLE_SCALE])
        circle_center(radius);
}

// uncomment these to sample
sample_lines();
//
translate([-5.5 * DIM_SAMPLE_SCALE, 0, 0])
sample_dimensions();

translate([-11 * DIM_SAMPLE_SCALE, 0, 0])
sample_dimensions_with_text(mytext="my variable");

//
translate([4 * DIM_SAMPLE_SCALE, 0, 0])
sample_circlecenter();
//
translate([-2 * DIM_SAMPLE_SCALE, 3 * DIM_SAMPLE_SCALE, 0])
sample_leaderlines();

translate([3 * DIM_SAMPLE_SCALE, 4 * DIM_SAMPLE_SCALE, 0])
sample_titleblock1();

translate([0 * DIM_SAMPLE_SCALE, -2 * DIM_SAMPLE_SCALE, 0])
sample_titleblock2();


