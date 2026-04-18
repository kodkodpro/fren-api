# typed: true
# frozen_string_literal: true

class RemoteConfig::Struct < T::Struct
  class Button < T::Struct
    const :text, String
    const :url, String
  end

  class BlockConfig < T::Struct
    const :title, String
    const :text, String
    const :emoji, T.nilable(String), default: nil
    const :button, T.nilable(Button), default: nil
  end

  const :block_app, T.nilable(BlockConfig), default: nil
  const :block_recording, T.nilable(BlockConfig), default: nil
  const :transcription_provider, T.nilable(RemoteConfig::TranscriptionProvider), default: nil
end
