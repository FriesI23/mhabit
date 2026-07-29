package io.github.friesi23.mhabit.collation

import java.text.Collator
import java.util.Locale

class CollationPlugin : CollationHostApi {
    override fun sortStrings(request: CollationRequest): List<String> {
        val collator = if (request.locale != null) {
            // Convert locale_SCRIPT_COUNTRY → locale-SCRIPT-COUNTRY (BCP 47)
            val locale = Locale.forLanguageTag(request.locale.replace("_", "-"))
            Collator.getInstance(locale)
        } else {
            Collator.getInstance()
        }
        collator.strength = Collator.TERTIARY

        return request.items.sortedWith(Comparator { a, b -> collator.compare(a.value, b.value) })
            .map { it.id }
    }
}
