<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:inv="http://com/exlibris/repository/acq/invoice/xmlbeans"
>
<xsl:output method="text" indent="no" omit-xml-declaration="yes" media-type="text/plain" />
<xsl:strip-space elements="inv:*"/>

<!--
	Flatten XML Export from Alma to fixed-length flat file for PRISM
-->
<xsl:template match="/inv:payment_data/inv:invoice_list">
	<xsl:for-each-group select="inv:invoice/inv:invoice_line_list/inv:invoice_line/inv:fund_info_list/inv:fund_info" group-by="substring(inv:ledger_name, 1, 3)">
		<!-- Jitterbit will pass a variable $LibraryName, with values of "uls", "Law", or "HSL" -->
		<xsl:if test="'[LibraryName]' = substring(inv:ledger_name, 1, 3) or '[LibraryName]' = concat('[Library', 'Name]')">
			<!--
				Header Line
			-->
			<!-- 1 - 10, Constant -->
			<xsl:text>LINE-COUNT</xsl:text>
			<!-- 11, Filler -->
			<xsl:text> </xsl:text>
			<!-- 12 - 17, Count -->
			<xsl:value-of select="count(current-group())" />
			<!-- LFs to be converted to CRLFs after the fact -->
			<xsl:text>&#10;</xsl:text>
			<!--
				Detail line
			-->
			<xsl:for-each select="current-group()">
				<!-- 1 - 6, Vendor Number -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">6</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:value-of select="substring-before(../../../../inv:vendor_FinancialSys_Code, '|')" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 7, Filler -->
				<xsl:text> </xsl:text>
				<!-- 8 - 22, Vendor Site Code -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">15</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:value-of select="substring-after(../../../../inv:vendor_FinancialSys_Code, '|')" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 23, Filler -->
				<xsl:text> </xsl:text>
				<!-- 24 - 38, Invoice Number -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">15</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:value-of select="../../../../inv:invoice_number" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 39, Filler -->
				<xsl:text> </xsl:text>
				<!-- 40 - 48, Invoice Date -->
				<xsl:call-template name="formatDate">
					<xsl:with-param name="pMDY">
						<xsl:value-of select="../../../../inv:invoice_date" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 49, Filler -->
				<xsl:text> </xsl:text>
				<!-- 50 - 61, Amount -->
				<xsl:call-template name="formatAmount">
					<xsl:with-param name="pAmount">
						<xsl:value-of select="inv:local_amount/inv:sum" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 62, Filler -->
				<xsl:text> </xsl:text>
				<!-- 63 - 87, Line Type -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">25</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:choose>
							<!-- Per FIS, everthing is FREIGHT or ITEM -->
							<xsl:when test="../../inv:line_type[text() = 'SHIPMENT']"><xsl:text>FREIGHT</xsl:text></xsl:when>
							<xsl:otherwise><xsl:text>ITEM</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
				<!-- 88, Filler -->
				<xsl:text> </xsl:text>
				<!-- 89 - 128, Description -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">40</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:value-of select="../../../../inv:vendor_code" />
						<xsl:text> </xsl:text>
						<xsl:value-of select="../../../../inv:unique_identifier" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 129, Filler -->
				<xsl:text> </xsl:text>
				<!-- 130 - 161, Debit Account Number -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">32</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:value-of select="inv:external_id" />
					</xsl:with-param>
				</xsl:call-template>
				<!-- 162, Filler -->
				<xsl:text> </xsl:text>
				<!-- 163 - 187, Source -->
				<xsl:call-template name="fixlenstring">
					<xsl:with-param name="pLength">25</xsl:with-param>
					<xsl:with-param name="pString">
						<xsl:choose>
							<xsl:when test="substring(inv:ledger_name, 1, 3) = 'uls'">ULS Library</xsl:when>
							<xsl:when test="substring(inv:ledger_name, 1, 3) = 'Law'">Law Library</xsl:when>
							<xsl:when test="substring(inv:ledger_name, 1, 4) = 'HSLS'">Falk Library</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text>&#10;</xsl:text>
			</xsl:for-each>
		</xsl:if>
	</xsl:for-each-group>
</xsl:template>

<!--
  Given input of pLength (int < 255) and pString (input string), output pString right padded to pLength
-->
<xsl:template name="fixlenstring">
	<xsl:param name="pLength" />
	<xsl:param name="pString" />
	<xsl:variable name="whitespace255"><xsl:text>                                                                                                                                                                                                                                                               </xsl:text></xsl:variable> 
	<xsl:value-of select="substring($pString, 1, $pLength)" />
	<xsl:if test="string-length($pString) &lt; $pLength">
		<xsl:value-of select="substring($whitespace255, 1, $pLength - string-length($pString))" />
	</xsl:if>
</xsl:template>

<!--
  Given input of pAmount (decimal) output number left padded with two significant fractional digits
-->
<xsl:template name="formatAmount">
	<xsl:param name="pAmount" />
	<xsl:variable name="whitespace12"><xsl:text>            </xsl:text></xsl:variable>
	<xsl:variable name="len">12</xsl:variable>
	<xsl:variable name="amt"><xsl:value-of select="format-number($pAmount, '#########0.00;-########0.00')" /></xsl:variable>
	<xsl:if test="string-length($amt) &lt; $len">
		<xsl:value-of select="substring($whitespace12, 1, $len - string-length($amt))" />
	</xsl:if>
	<xsl:value-of select="$amt" />
</xsl:template>

<!--
  Give input of pMDY of the format MM-DD-YYYY or MM/DD/YYYY, output DD-MON-YY.
-->
<xsl:template name="formatDate">
	<xsl:param name="pMDY" />
	<xsl:value-of select="substring($pMDY, 4, 2)" />
	<xsl:text>-</xsl:text>
	<xsl:choose>
		<xsl:when test="substring($pMDY, 1, 2) = '01'">JAN</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '02'">FEB</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '03'">MAR</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '04'">APR</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '05'">MAY</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '06'">JUN</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '07'">JUL</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '08'">AUG</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '09'">SEP</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '10'">OCT</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '11'">NOV</xsl:when>
		<xsl:when test="substring($pMDY, 1, 2) = '12'">DEC</xsl:when>
		<xsl:otherwise><xsl:text>   </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:text>-</xsl:text>
	<xsl:value-of select="substring($pMDY, 9, 2)" />
</xsl:template>

</xsl:stylesheet>
