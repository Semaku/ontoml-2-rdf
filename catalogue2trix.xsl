<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl [
	<!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
	<!ENTITY plib "http://purl.org/plib/dictionary.owl#">
	<!ENTITY xsd "http://www.w3.org/2001/XMLSchema#">
	<!ENTITY dc "http://purl.org/dc/terms/">
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:cat="urn:iso:std:iso:ts:29002:-10:ed-1:tech:xml-schema:catalogue" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:id="urn:iso:std:iso:ts:29002:-5:ed-1:tech:xml-schema:identifier" xmlns:val="urn:iso:std:iso:ts:29002:-10:ed-1:tech:xml-schema:value" xmlns:bas="urn:iso:std:iso:ts:29002:-4:ed-1:tech:xml-schema:basic" xmlns:vxt="urn:x-value-extensions:schema:value" xsi:type="cat:catalogue_Type" xsi:schemaLocation="urn:iso:std:iso:ts:29002:-10:ed-1:tech:xml-schema:catalogue http://www.paradine.net/schema/dictionary/1.0/ontoML/ISO29002/catalogue.xsd" xmlns:ontoml="urn:iso:std:iso:is:13584:-32:ed-1:tech:xml-schema:ontoml" xmlns="http://www.w3.org/2004/03/trix/trix-1/" exclude-result-prefixes="xsl xs fo fn bas cat id ontoml val vxt">
	<xsl:import href="irdi2uri.xsl"/>
	<xsl:output indent="no"/>
	<xsl:function name="ontoml:gen-id">
		<xsl:param name="node"/>
		<xsl:value-of select="concat(ontoml:irdi2uri($node/ancestor::cat:item[1]/@information_supplier_reference_string),'#',translate(generate-id($node),'#:','- -'))"/>
	</xsl:function>
	<xsl:template match="cat:catalogue">
		<trix xmlns="http://www.w3.org/2004/03/trix/trix-1/" xsi:schemaLocation="http://www.w3.org/2004/03/trix/trix-1/ http://www.w3.org/2004/03/trix/trix-1/trix-1.0.xsd">
			<xsl:apply-templates/>
		</trix>
	</xsl:template>
	<xsl:template match="cat:item">
		<xsl:variable name="itemUri" select="ontoml:irdi2uri(@information_supplier_reference_string)"/>
		<xsl:variable name="graphUri" select="ontoml:irdi2graphuri(@information_supplier_reference_string)"/>
		<graph>
			<uri>
				<xsl:value-of select="$graphUri"/>
			</uri>
			<triple>
				<uri>
					<xsl:value-of select="$graphUri"/>
				</uri>
				<uri>&dc;created</uri>
				<typedLiteral datatype="&xsd;dateTime">
					<xsl:value-of select="current-dateTime()"/>
				</typedLiteral>
			</triple>
			<xsl:apply-templates select="@*">
				<xsl:with-param name="subject" select="$itemUri"/>
			</xsl:apply-templates>
			<xsl:apply-templates>
				<xsl:with-param name="subject" select="$itemUri"/>
			</xsl:apply-templates>
		</graph>
	</xsl:template>
	<xsl:template match="cat:reference">
		<xsl:param name="subject"/>
		<xsl:apply-templates select="@*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="cat:designation/bas:local_string/bas:content">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="@reference_number">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;referenceNumber</uri>
			<plainLiteral>
				<xsl:value-of select="."/>
			</plainLiteral>
		</triple>
	</xsl:template>
	<xsl:template match="bas:content">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdfs;label</uri>
			<plainLiteral>
				<xsl:value-of select="."/>
			</plainLiteral>
		</triple>
	</xsl:template>
	<xsl:template match="@information_supplier_reference_string">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;irdi</uri>
			<plainLiteral>
				<xsl:value-of select="."/>
			</plainLiteral>
		</triple>
	</xsl:template>
	<xsl:template match="@class_ref">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdf;type</uri>
			<uri>
				<xsl:value-of select="ontoml:irdi2defuri(.)"/>
			</uri>
		</triple>
	</xsl:template>
	<xsl:template match="cat:property_value|val:field|val:property_value">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>
				<xsl:value-of select="ontoml:irdi2defuri(@property_ref)"/>
			</uri>
			<xsl:apply-templates select="*" mode="object"/>
		</triple>
		<xsl:apply-templates select="val:measure_single_number_value|val:measure_qualified_number_value|val:null_value|val:composite_value|val:measure_range_value" mode="subject"/>
	</xsl:template>
	<xsl:template match="val:environment" mode="object"/>
	<xsl:template match="val:qualified_value[not(@no_value_type)]|val:upper_value|val:lower_value" mode="object">
		<xsl:apply-templates select="val:presentation_value" mode="object"/>
	</xsl:template>
	<xsl:template match="val:presentation_value" mode="object">
		<xsl:apply-templates select="*" mode="object"/>
	</xsl:template>
	<xsl:template match="*[@no_value_type='NK']" mode="object">
		<uri>&plib;notKnown</uri>
	</xsl:template>
	<xsl:template match="*[@no_value_type='NA']" mode="object">
		<uri>&plib;notApplicable</uri>
	</xsl:template>
	<xsl:template match="*[@no_value_type='NP']" mode="object">
		<uri>&plib;notPublished</uri>
	</xsl:template>
	<xsl:template match="*[@no_value_type='TBD']" mode="object">
		<uri>&plib;toBeDefined</uri>
	</xsl:template>
	<xsl:template match="vxt:upper_boundary|vxt:lower_boundary" mode="object">
		<xsl:choose>
			<xsl:when test="text()='CLOSED'">
				<uri>&plib;closedBoundary</uri>
			</xsl:when>
			<xsl:when test="text()='OPEN'">
				<uri>&plib;openBoundary</uri>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="val:string_value" mode="object">
		<plainLiteral>
			<xsl:value-of select="."/>
		</plainLiteral>
	</xsl:template>
	<xsl:template match="val:controlled_value" mode="object">
		<uri>
			<xsl:value-of select="ontoml:irdi2defuri(@value_ref)"/>
		</uri>
	</xsl:template>
	<xsl:template match="val:date_value" mode="object">
		<typedLiteral datatype="&xsd;date">
			<xsl:value-of select="."/>
		</typedLiteral>
	</xsl:template>
	<xsl:template match="val:boolean_value" mode="object">
		<typedLiteral datatype="&xsd;boolean">
			<xsl:value-of select="."/>
		</typedLiteral>
	</xsl:template>
	<xsl:template match="val:real_value" mode="object">
		<typedLiteral datatype="&xsd;float">
			<xsl:value-of select="."/>
		</typedLiteral>
	</xsl:template>
	<xsl:template match="val:integer_value" mode="object">
		<typedLiteral datatype="&xsd;integer">
			<xsl:value-of select="."/>
		</typedLiteral>
	</xsl:template>
	<!-- templates to match complex values -->
	<xsl:template match="val:measure_single_number_value|val:measure_qualified_number_value|val:null_value|val:composite_value|val:measure_range_value" mode="object">
		<uri>
			<xsl:value-of select="ontoml:gen-id(.)"/>
		</uri>
	</xsl:template>
	<xsl:template match="val:item_reference_value" mode="object">
		<xsl:variable name="itemLocalRef" select="@item_local_ref"/>
		<uri>
			<xsl:value-of select="ontoml:irdi2uri(/cat:catalogue/cat:item[@local_id = $itemLocalRef]/@information_supplier_reference_string)"/>
		</uri>
	</xsl:template>
	<xsl:template match="val:measure_single_number_value" mode="subject">
		<xsl:variable name="subject" select="ontoml:gen-id(.)"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdf;type</uri>
			<uri>&plib;QuantitativeValue</uri>
		</triple>
		<xsl:call-template name="label">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:call-template>
		<xsl:apply-templates select="@*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates>
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="val:measure_qualified_number_value" mode="subject">
		<xsl:variable name="subject" select="ontoml:gen-id(.)"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdf;type</uri>
			<uri>&plib;QuantitativeLevelTypeValue</uri>
		</triple>
		<xsl:call-template name="label">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:call-template>
		<xsl:apply-templates select="@*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates>
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="../val:environment/*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="val:null_value" mode="subject">
		<xsl:variable name="subject" select="ontoml:gen-id(.)"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdf;type</uri>
			<uri>&plib;NullValue</uri>
		</triple>
		<xsl:call-template name="label">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:call-template>
		<xsl:apply-templates select="@*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates>
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="../val:environment/*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="val:composite_value" mode="subject">
		<xsl:variable name="subject" select="ontoml:gen-id(.)"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdf;type</uri>
			<uri>&plib;CompositeValue</uri>
		</triple>
		<xsl:apply-templates>
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="val:measure_range_value" mode="subject">
		<xsl:variable name="subject" select="ontoml:gen-id(.)"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdf;type</uri>
			<uri>&plib;MeasureRangeValue</uri>
		</triple>
		<xsl:apply-templates select="@*">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
		<xsl:apply-templates>
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="@presentation_UOM_ref">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;hasUnitOfMeasure</uri>
			<uri>
				<xsl:value-of select="ontoml:irdi2defuri(.)"/>
			</uri>
		</triple>
	</xsl:template>
	<xsl:template match="val:measure_single_number_value/val:presentation_value">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;hasValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="val:upper_value">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;upperValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="vxt:upper_boundary">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;upperBoundary</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="val:lower_value">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;lowerValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="vxt:lower_boundary">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;lowerBoundary</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="*[@qualifier_code='MIN']">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;hasMinValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="*[@qualifier_code='NOM']">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;hasNomValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="*[@qualifier_code='TYP']">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;hasTypValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<xsl:template match="*[@qualifier_code='MAX']">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&plib;hasMaxValue</uri>
			<xsl:apply-templates select="." mode="object"/>
		</triple>
	</xsl:template>
	<!-- templates for creating labels -->
	<xsl:template name="label">
		<xsl:param name="subject"/>
		<triple>
			<uri>
				<xsl:value-of select="$subject"/>
			</uri>
			<uri>&rdfs;label</uri>
			<plainLiteral>
				<xsl:apply-templates select="*" mode="label"/>
			</plainLiteral>
		</triple>
	</xsl:template>
	<xsl:template match="val:measure_qualified_number_value/*[1]|val:null_value/*[1]" mode="label">
		<xsl:value-of select="concat(@qualifier_code, ': ')"/>
		<xsl:apply-templates select="." mode="value"/>
	</xsl:template>
	<xsl:template match="val:measure_qualified_number_value/*[position()>1]|val:null_value/*[position()>1]" mode="label">
		<xsl:value-of select="concat(', ', @qualifier_code, ': ')"/>
		<xsl:apply-templates select="." mode="value"/>
	</xsl:template>
	<xsl:template match="*[not(@no_value_type)]" mode="value">
		<xsl:apply-templates select="val:presentation_value" mode="label"/>
	</xsl:template>
	<xsl:template match="*[@no_value_type]" mode="value">
		<xsl:value-of select="@no_value_type"/>
	</xsl:template>
	<xsl:template match="val:presentation_value" mode="label">
		<xsl:apply-templates select="*" mode="label"/>
	</xsl:template>
	<xsl:template match="val:real_value|val:integer_value" mode="label">
		<xsl:value-of select="."/>
	</xsl:template>
	<!-- Ignore all other nodes -->
	<xsl:template match="node() | @*"/>
</xsl:stylesheet>
