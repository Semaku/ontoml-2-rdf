<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl [
	<!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<!ENTITY plib "http://purl.org/plib/dictionary.owl#">
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:rdf="&rdf;" xmlns:plib="&plib;" xmlns:ontoml="urn:iso:std:iso:is:13584:-32:ed-1:tech:xml-schema:ontoml">
	<xsl:variable name="uri_lookup" select="document('uri_lookup.rdf')/rdf:RDF"/>
	<xsl:function name="ontoml:irdi2uri">
		<xsl:param name="irdi"/>
		<xsl:variable name="irdi_tokens" select="tokenize($irdi,'#')"/>
		<xsl:value-of select="concat(ontoml:rai2baseuri($irdi_tokens[1]),ontoml:di2ref($irdi_tokens[2]))"/>
	</xsl:function>
	<xsl:function name="ontoml:irdi2graphuri">
		<xsl:param name="irdi"/>
		<xsl:variable name="irdi_tokens" select="tokenize($irdi,'#')"/>
		<xsl:value-of select="concat(ontoml:rai2graphuri($irdi_tokens[1]),ontoml:di2ref($irdi_tokens[2]))"/>
	</xsl:function>
	<xsl:function name="ontoml:irdi2defuri">
		<xsl:param name="irdi"/>
		<xsl:variable name="irdi_tokens" select="tokenize($irdi,'#')"/>
		<xsl:value-of select="concat(ontoml:rai2defuri($irdi_tokens[1]),ontoml:di2ref($irdi_tokens[2]))"/>
	</xsl:function>
	<xsl:function name="ontoml:irdi2qname">
		<xsl:param name="irdi"/>
		<xsl:variable name="irdi_tokens" select="tokenize($irdi,'#')"/>
		<xsl:value-of select="concat(ontoml:rai2prefix($irdi_tokens[1]),':',ontoml:di2ref($irdi_tokens[2]))"/>
	</xsl:function>
	<xsl:function name="ontoml:di2ref">
		<xsl:param name="di"/>
		<xsl:choose>
			<xsl:when test="starts-with($di,'01')">
				<xsl:value-of select="concat('C_',substring-after($di,'-'))"/>
			</xsl:when>
			<xsl:when test="starts-with($di,'02')">
				<xsl:value-of select="concat('P_',substring-after($di,'-'))"/>
			</xsl:when>
			<xsl:when test="starts-with($di,'05')">
				<xsl:value-of select="concat('U_',substring-after($di,'-'))"/>
			</xsl:when>
			<xsl:when test="starts-with($di,'07')">
				<xsl:value-of select="concat('V_',substring-after($di,'-'))"/>
			</xsl:when>
			<xsl:when test="starts-with($di,'09')">
				<xsl:value-of select="concat('D_',substring-after($di,'-'))"/>
			</xsl:when>
			<xsl:when test="starts-with($di,'11')">
				<xsl:value-of select="concat('O_',substring-after($di,'-'))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($di,'-','_')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="ontoml:rai2baseuri">
		<xsl:param name="rai"/>
		<xsl:value-of select="$uri_lookup/rdf:Description[plib:rai=$rai]/@rdf:about"/>
	</xsl:function>
	<xsl:function name="ontoml:rai2graphuri">
		<xsl:param name="rai"/>
		<xsl:value-of select="$uri_lookup/rdf:Description[plib:rai=$rai]/plib:graph"/>
	</xsl:function>
	<xsl:function name="ontoml:rai2defuri">
		<xsl:param name="rai"/>
		<xsl:value-of select="$uri_lookup/rdf:Description[plib:rai=$rai]/plib:def"/>
	</xsl:function>
	<xsl:function name="ontoml:rai2prefix">
		<xsl:param name="rai"/>
		<xsl:value-of select="$uri_lookup/rdf:Description[plib:rai=$rai]/plib:prefix"/>
	</xsl:function>
</xsl:stylesheet>
