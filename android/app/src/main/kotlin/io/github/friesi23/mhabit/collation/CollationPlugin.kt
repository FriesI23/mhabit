package io.github.friesi23.mhabit.collation

import android.icu.text.AlphabeticIndex
import android.icu.text.CollationKey
import android.icu.text.Collator
import android.icu.util.ULocale

class CollationPlugin : CollationHostApi {
    override fun sortStrings(request: CollationRequest): List<String> {
        val uLocale = request.locale?.takeIf { it.isNotBlank() }?.let {
            // Convert locale_SCRIPT_COUNTRY → locale-SCRIPT-COUNTRY (BCP 47)
            ULocale.forLanguageTag(it.replace("_", "-"))
        } ?: ULocale.getDefault()

        val collator = Collator.getInstance(uLocale).apply {
            strength = Collator.TERTIARY
            decomposition = Collator.CANONICAL_DECOMPOSITION
        }

        val index = AlphabeticIndex<Any?>(uLocale)

        return request.items.asSequence().map { item ->
            SortEntry(
                id = item.id,
                value = item.value,
                bucket = index.getBucketIndex(item.value),
                key = collator.getCollationKey(item.value),
            )
        }.sortedWith(
            compareBy(SortEntry::bucket).thenBy(SortEntry::key).thenBy(SortEntry::value)
                .thenBy(SortEntry::id),
        ).map { it.id }.toList()
    }

    private data class SortEntry(
        val id: String,
        val value: String,
        val bucket: Int,
        val key: CollationKey,
    )
}