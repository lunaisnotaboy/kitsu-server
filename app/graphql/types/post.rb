class Types::Post < Types::BaseObject
  implements Types::Interface::WithTimestamps

  description 'A post that is visible to your followers and globally in the news-feed.'

  field :id, ID, null: false

  field :author, Types::Profile,
    null: false,
    description: 'The user who created this post.',
    method: :user

  field :media, Types::Interface::Media,
    null: true,
    description: 'The media tagged in this post.'

  field :is_spoiler, Boolean,
    null: false,
    description: 'If this post spoils the tagged media.',
    method: :spoiler?

  field :is_nsfw, Boolean,
    null: false,
    description: 'If a post is Not-Safe-for-Work.',
    method: :nsfw?

  field :content, String,
    null: true,
    description: 'Unmodified content.'

  field :content_formatted, String,
    null: true,
    description: 'Html formatted content.'

  field :locked_by, Types::Profile,
    null: true,
    description: 'The user who locked this post.'

  field :locked_at, GraphQL::Types::ISO8601DateTime,
    null: true,
    description: 'When this post was locked.'

  field :locked_reason, Types::Enum::LockedReason,
    null: true,
    description: 'The reason why this post was locked.'

  field :comments, Types::Comment.connection_type, null: false do
    description 'All comments on this post'
    argument :sort, Loaders::CommentsLoader.sort_argument, required: false
  end

  def comments(sort: [{ on: :created_at, direction: :asc }])
    Loaders::CommentsLoader.connection_for({
      find_by: :post_id,
      sort: sort,
      where: { parent_id: nil }
    }, object.id)
  end

  field :likes, Types::Profile.connection_type, null: false do
    description 'Users that have liked this post'
    argument :sort, Loaders::PostLikesLoader.sort_argument, required: false
  end

  def likes(sort: [{ on: :created_at, direction: :desc }])
    Loaders::PostLikesLoader.connection_for({
      find_by: :post_id,
      sort: sort
    }, object.id).then do |likes|
      Loaders::RecordLoader.for(User, token: context[:token]).load_many(likes.map(&:user_id))
    end
  end

  field :follows, Types::Profile.connection_type,
    null: false,
    description: 'Users that are watching this post'

  def follows
    Loaders::AssociationLoader.for(object.class, :post_follows).scope(object).then do |follows|
      Loaders::RecordLoader.for(User, token: context[:token]).load_many(follows.pluck(:user_id))
    end
  end
end
