module Json
  module PurposeHelper

    def hash_for_purpose(purpose, with = nil)
      {
        type: "purpose",
        id: purpose.id,
        description: purpose.description
      }
    end

  end
end
