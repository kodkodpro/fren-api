# typed: true
# frozen_string_literal: true

class Paywall::Data < T::Struct
  class Bullet < T::Struct
    const :title, String
    const :description, String
    const :icon, String
    const :icon_color, String
  end

  class Product < T::Struct
    const :apple_product_id, String
  end

  class Content < T::Struct
    const :title, String
    const :bullets, T::Array[Bullet], default: []
  end

  const :default_locale, String, default: "en"
  const :locales, T::Hash[String, Content], default: {}
  const :products, T::Array[Product], default: []

  sig { params(device_language: T.nilable(String)).returns(Content) }
  def localized_content(device_language)
    available_locales = normalized_locales

    content_locale_candidates(device_language).each do |locale|
      content = available_locales[locale]
      return content if content
    end

    raise KeyError, "Paywall data must include an en locale"
  end

  sig { params(locale: String).returns(T::Boolean) }
  def locale_available?(locale)
    normalized_locale = self.class.normalize_locale(locale)
    return false unless normalized_locale

    normalized_locales.key?(normalized_locale)
  end

  class << self
    sig { params(device_language: T.nilable(String)).returns(T.nilable(String)) }
    def normalize_locale(device_language)
      locale = device_language.to_s.strip
      return nil if locale.blank?

      locale.tr("_", "-").downcase
    end
  end

  private

  sig { params(device_language: T.nilable(String)).returns(T::Array[String]) }
  def content_locale_candidates(device_language)
    locale = self.class.normalize_locale(device_language)
    candidates = [locale, base_locale(locale), self.class.normalize_locale(default_locale), "en"]

    candidates.compact.uniq
  end

  sig { params(locale: T.nilable(String)).returns(T.nilable(String)) }
  def base_locale(locale)
    locale&.split("-")&.first
  end

  sig { returns(T::Hash[String, Content]) }
  def normalized_locales
    locales.each_with_object({}) do |(locale, content), hash|
      normalized_locale = self.class.normalize_locale(locale)
      hash[normalized_locale] = content if normalized_locale
    end
  end
end
