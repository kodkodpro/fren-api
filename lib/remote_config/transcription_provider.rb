# typed: true
# frozen_string_literal: true

class RemoteConfig::TranscriptionProvider < T::Enum
  enums do
    OpenAI = new("openai")
    ElevenLabs = new("elevenlabs")
  end
end
