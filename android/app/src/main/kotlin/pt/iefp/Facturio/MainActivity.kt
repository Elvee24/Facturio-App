package pt.iefp.Facturio

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			CHANNEL_NAME,
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"applyIcon" -> {
					val iconKey = call.argument<String>("iconKey")
					result.success(applyIcon(iconKey ?: DEFAULT_ICON_KEY))
				}

				"getCurrentIcon" -> result.success(getCurrentIconKey())
				else -> result.notImplemented()
			}
		}
	}

	private fun applyIcon(iconKey: String): String {
		val targetAlias = iconAliases[iconKey] ?: return "invalidIcon"
		val currentIconKey = getCurrentIconKey()
		if (currentIconKey == iconKey) {
			return "alreadySynced"
		}

		iconAliases.forEach { (candidateKey, aliasName) ->
			val desiredState = if (candidateKey == iconKey) {
				PackageManager.COMPONENT_ENABLED_STATE_ENABLED
			} else {
				PackageManager.COMPONENT_ENABLED_STATE_DISABLED
			}

			packageManager.setComponentEnabledSetting(
				ComponentName(this, aliasName),
				desiredState,
				PackageManager.DONT_KILL_APP,
			)
		}

		getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
			.edit()
			.putString(SELECTED_ICON_KEY, iconKey)
			.apply()

		return if (targetAlias.isNotEmpty()) "synced" else "failed"
	}

	private fun getCurrentIconKey(): String {
		iconAliases.forEach { (iconKey, aliasName) ->
			val state = packageManager.getComponentEnabledSetting(ComponentName(this, aliasName))
			val isEnabled = when (state) {
				PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
				PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> iconKey == DEFAULT_ICON_KEY
				else -> false
			}

			if (isEnabled) {
				return iconKey
			}
		}

		return getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
			.getString(SELECTED_ICON_KEY, DEFAULT_ICON_KEY)
			?: DEFAULT_ICON_KEY
	}

	companion object {
		private const val CHANNEL_NAME = "facturio/app_icon"
		private const val PREFS_NAME = "facturio_icon_prefs"
		private const val SELECTED_ICON_KEY = "selected_icon_key"
		private const val DEFAULT_ICON_KEY = "official"

		private val iconAliases = linkedMapOf(
			"official" to "pt.iefp.Facturio.DefaultIconAlias",
			"calculator" to "pt.iefp.Facturio.CalculatorIconAlias",
			"money" to "pt.iefp.Facturio.MoneyIconAlias",
			"documents" to "pt.iefp.Facturio.DocumentsIconAlias",
			"chart" to "pt.iefp.Facturio.ChartIconAlias",
			"business" to "pt.iefp.Facturio.BusinessIconAlias",
		)
	}
}
