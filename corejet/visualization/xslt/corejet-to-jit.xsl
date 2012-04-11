<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text" omit-xml-declaration="yes"/>
<xsl:template match="//requirementscatalogue">
// corejet-output.js, generated from Corejet Requirements Catalogue

		/**
		 * HSV to RGB color conversion
		 *
		 * H runs from 0 to 360 degrees
		 * S and V run from 0 to 100
		 * 
		 * Ported from the excellent java algorithm by Eugene Vishnevsky at:
		 * http://www.cs.rit.edu/~ncs/color/t_convert.html
		 */
		function hsvToRgb(h, s, v) {
			var r, g, b;
			var i;
			var f, p, q, t;
	
			// Make sure our arguments stay in-range
			h = Math.max(0, Math.min(360, h));
			s = Math.max(0, Math.min(100, s));
			v = Math.max(0, Math.min(100, v));
	
			// We accept saturation and value arguments from 0 to 100 because that's
			// how Photoshop represents those values. Internally, however, the
			// saturation and value are calculated from a range of 0 to 1. We make
			// That conversion here.
			s /= 100;
			v /= 100;
	
			if(s == 0) {
				// Achromatic (grey)
				r = g = b = v;
				return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
			}
	
			h /= 60; // sector 0 to 5
			i = Math.floor(h);
			f = h - i; // factorial part of h
			p = v * (1 - s);
			q = v * (1 - s * f);
			t = v * (1 - s * (1 - f));

			switch(i) {
				case 0:
					r = v;
					g = t;
					b = p;
					break;
			
				case 1:
					r = q;
					g = v;
					b = p;
					break;
			
				case 2:
					r = p;
					g = v;
					b = t;
					break;
			
				case 3:
					r = p;
					g = q;
					b = v;
					break;
			
				case 4:
					r = t;
					g = p;
					b = v;
					break;
			
				default: // case 5:
					r = v;
					g = p;
					b = q;
			}
	
			return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
		};
        
        var custom_color_for = function(num_passing, num_pending, total) {
            var h = 120 * (num_passing / (total));
			var s = 100 * ((total - num_pending) / total);
			var v = 50 * ((total - num_pending) / total) + 50;

			if (total == 0)
			{
				h = 0;
				s = 0;
				v = 50;
			}

			var rgb = hsvToRgb(h, s, v)
			
            red = rgb[0];
            green = rgb[1];
			blue = rgb[2]
			
            return 'rgb('+red+','+green+','+blue+')';
        };


var metadata = {
  'project':  "<xsl:value-of select="@project"/>",
  'testTime': "<xsl:value-of select="@testTime"/>"
};

var json = {
  'id':       'root',
  'name':     "<xsl:value-of select="@project"/>",
  'data':     {},
  'children': [<xsl:apply-templates select="epic"/>
  ]
};
</xsl:template>
<xsl:template match="epic">
  <xsl:variable name="num_passing" select="sum(story/scenario[@testStatus='pass']/parent::story/@points) * count(story/scenario[@testStatus='pass'])"/>
  <xsl:variable name="num_pending" select="sum(story/scenario[@testStatus='pending']/parent::story/@points) * count(story/scenario[@testStatus='pending'])"/>
  <xsl:variable name="total_scenarios" select="sum(story/scenario/parent::story/@points) * count(story/scenario)"/>
    {
      'id':   "epic-<xsl:value-of select="@id"/>",
      'name': "<xsl:value-of select="@title"/>",
      'data': {
        '$area':  <xsl:value-of select="sum(child::story/@points)"/> * 10,
        '$color': custom_color_for(<xsl:number value="$num_passing"/>, <xsl:number value="$num_pending"/>, <xsl:number value="$total_scenarios"/>)
      },
      'children': [<xsl:apply-templates select="story"/>
      ]
    }<xsl:choose><xsl:when test="following-sibling::epic"><xsl:text>,</xsl:text></xsl:when></xsl:choose>
</xsl:template>
<xsl:template match="story">
  <xsl:variable name="num_passing" select="count(scenario[@testStatus='pass'])"/>
  <xsl:variable name="num_pending" select="count(scenario[@testStatus='pending'])"/>
  <xsl:variable name="total_scenarios" select="count(scenario)"/>
        {
          'id':   "story-<xsl:value-of select="@id"/>",
          'name': "<xsl:value-of select="@id"/>",
          'data': {
            'title':  "<xsl:value-of select="@title"/>",
            '$area':  <xsl:call-template name="area-for-story"/>,
            '$color': custom_color_for(<xsl:number value="$num_passing"/>, <xsl:number value="$num_pending"/>, <xsl:number value="$total_scenarios"/>)
          },
          'children': [<xsl:apply-templates select="scenario"/>
          ]
        }<xsl:choose><xsl:when test="following-sibling::story"><xsl:text>,</xsl:text></xsl:when></xsl:choose>
</xsl:template>
<xsl:template match="scenario">
            {
              'id':   "story-<xsl:value-of select="parent::node()/@id"/>-scenario-<xsl:value-of select="@name"/>",
              'name': "",
              'data': {
                'title':  "<xsl:value-of select="@name"/>",
                '$area':  <xsl:call-template name="area-for-scenario"/>,
                '$color': <xsl:call-template name="status-color"/>
              },
              'children': []
            }<xsl:choose><xsl:when test="following-sibling::scenario"><xsl:text>,</xsl:text></xsl:when></xsl:choose>
</xsl:template>
<xsl:template name="area-for-story">
  <xsl:choose>
    <xsl:when test="@points=''">10</xsl:when>
    <xsl:when test="not(@points)">10</xsl:when>
    <xsl:otherwise><xsl:value-of select="@points"/> * 10</xsl:otherwise>
  </xsl:choose>
</xsl:template>
<xsl:template name="area-for-scenario">
  <xsl:text>(</xsl:text>
  <xsl:choose>
    <xsl:when test="../@points=''">1</xsl:when>
    <xsl:when test="not(../@points)">1</xsl:when>
    <xsl:otherwise><xsl:value-of select="../@points"/></xsl:otherwise>
  </xsl:choose>
  <xsl:text> / </xsl:text>
  <xsl:value-of select="count(../scenario)"/>
  <xsl:text>) * 10</xsl:text>
</xsl:template>
<xsl:template name="status-color">
  <xsl:choose>
    <xsl:when test="@testStatus='pass'">'#0a0'</xsl:when>
    <xsl:when test="@testStatus='pending'">'#aa0'</xsl:when>
    <xsl:otherwise>'#a00'</xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
