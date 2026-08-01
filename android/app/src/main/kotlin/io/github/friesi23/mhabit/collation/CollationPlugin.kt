package io.github.friesi23.mhabit.collation

import android.icu.text.Collator
import android.icu.util.ULocale

class CollationPlugin : CollationHostApi {
    override fun sortStrings(request: CollationRequest): List<String> {
        val uLocale = request.locale
            ?.takeIf { it.isNotBlank() }
            ?.let { ULocale.forLanguageTag(it.replace("_", "-")) }
            ?.setKeywordValue("colNumeric", "yes")
            ?: ULocale.getDefault().setKeywordValue("colNumeric", "yes")

        val collator = Collator.getInstance(uLocale).apply {
            strength = Collator.TERTIARY
            decomposition = Collator.CANONICAL_DECOMPOSITION
        }

        return sortByCollationKey(request.items) { collator.getCollationKey(it) }
    }
}