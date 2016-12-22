require 'spec_helper'

RSpec.describe JSONAPI::Authorization::DefaultPunditAuthorizer do
  include PunditStubs
  fixtures :all

  let(:source_record) { Article.new }
  let(:authorizer) { described_class.new({}) }

  describe '#find' do
    subject(:method_call) do
      -> { authorizer.find(source_record) }
    end

    context 'authorized for index? on record' do
      before { allow_action('index?', source_record) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for index? on record' do
      before { disallow_action('index?', source_record) }
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end
  end

  describe '#show' do
    subject(:method_call) do
      -> { authorizer.show(source_record) }
    end

    context 'authorized for show? on record' do
      before { allow_action('show?', source_record) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for show? on record' do
      before { disallow_action('show?', source_record) }
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end
  end

  describe '#show_relationship' do
    subject(:method_call) do
      -> { authorizer.show_relationship(source_record, related_record) }
    end

    context 'authorized for show? on source record' do
      before { allow_action('show?', source_record) }

      context 'related record is present' do
        let(:related_record) { Comment.new }

        context 'authorized for show on related record' do
          before { allow_action('show?', related_record) }
          it { is_expected.not_to raise_error }
        end

        context 'unauthorized for show on related record' do
          before { disallow_action('show?', related_record) }
          it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
        end
      end

      context 'related record is nil' do
        let(:related_record) { nil }
        it { is_expected.not_to raise_error }
      end
    end

    context 'unauthorized for show? on source record' do
      before { disallow_action('show?', source_record) }

      context 'related record is present' do
        let(:related_record) { Comment.new }

        context 'authorized for show on related record' do
          before { allow_action('show?', related_record) }
          it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
        end

        context 'unauthorized for show on related record' do
          before { disallow_action('show?', related_record) }
          it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
        end
      end

      context 'related record is nil' do
        let(:related_record) { nil }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end
  end

  describe '#show_related_resource' do
    subject(:method_call) do
      -> { authorizer.show_related_resource(source_record, related_record) }
    end

    context 'authorized for show? on source record' do
      before { allow_action('show?', source_record) }

      context 'related record is present' do
        let(:related_record) { Comment.new }

        context 'authorized for show on related record' do
          before { allow_action('show?', related_record) }
          it { is_expected.not_to raise_error }
        end

        context 'unauthorized for show on related record' do
          before { disallow_action('show?', related_record) }
          it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
        end
      end

      context 'related record is nil' do
        let(:related_record) { nil }
        it { is_expected.not_to raise_error }
      end
    end

    context 'unauthorized for show? on source record' do
      before { disallow_action('show?', source_record) }

      context 'related record is present' do
        let(:related_record) { Comment.new }

        context 'authorized for show on related record' do
          before { allow_action('show?', related_record) }
          it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
        end

        context 'unauthorized for show on related record' do
          before { disallow_action('show?', related_record) }
          it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
        end
      end

      context 'related record is nil' do
        let(:related_record) { nil }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end
  end

  describe '#show_related_resources' do
    subject(:method_call) do
      -> { authorizer.show_related_resources(source_record) }
    end

    context 'authorized for show? on record' do
      before { allow_action('show?', source_record) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for show? on record' do
      before { disallow_action('show?', source_record) }
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end
  end

  describe '#replace_fields' do
    let(:related_records) { Array.new(3) { Comment.new } }
    subject(:method_call) do
      -> { authorizer.replace_fields(source_record, related_records) }
    end

    context 'authorized for update? on source record' do
      before { allow_action('update?', source_record) }

      context 'related records is empty' do
        let(:related_records) { [] }
        it { is_expected.not_to raise_error }
      end

      context 'authorized for update? on all of the related records' do
        before { related_records.each { |r| allow_action('update?', r) } }
        it { is_expected.not_to raise_error }
      end

      context 'unauthorized for update? on any of the related records' do
        let(:related_records) { [Comment.new(id: 1), Comment.new(id: 2)] }
        before do
          allow_action('update?', related_records.first)
          disallow_action('update?', related_records.last)
        end

        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end

    context 'unauthorized for update? on source record' do
      before { disallow_action('update?', source_record) }

      context 'related records is empty' do
        let(:related_records) { [] }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end

      context 'authorized for update? on all of the related records' do
        before { related_records.each { |r| allow_action('update?', r) } }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end

      context 'unauthorized for update? on any of the related records' do
        let(:related_records) { [Comment.new(id: 1), Comment.new(id: 2)] }
        before do
          allow_action('update?', related_records.first)
          disallow_action('update?', related_records.last)
        end

        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end
  end

  describe '#create_resource' do
    let(:related_records) { Array.new(3) { Comment.new } }
    let(:source_class) { source_record.class }
    subject(:method_call) do
      -> { authorizer.create_resource(source_class, related_records) }
    end

    context 'authorized for create? on source class' do
      before { allow_action('create?', source_class) }

      context 'related records is empty' do
        let(:related_records) { [] }
        it { is_expected.not_to raise_error }
      end

      context 'authorized for update? on all of the related records' do
        before { related_records.each { |r| allow_action('update?', r) } }
        it { is_expected.not_to raise_error }
      end

      context 'unauthorized for update? on any of the related records' do
        let(:related_records) { [Comment.new(id: 1), Comment.new(id: 2)] }
        before do
          allow_action('update?', related_records.first)
          disallow_action('update?', related_records.last)
        end

        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end

    context 'unauthorized for create? on source class' do
      before { disallow_action('create?', source_class) }

      context 'related records is empty' do
        let(:related_records) { [] }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end

      context 'authorized for update? on all of the related records' do
        before { related_records.each { |r| allow_action('update?', r) } }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end

      context 'unauthorized for update? on any of the related records' do
        let(:related_records) { [Comment.new(id: 1), Comment.new(id: 2)] }
        before do
          allow_action('update?', related_records.first)
          disallow_action('update?', related_records.last)
        end

        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end
  end

  describe '#remove_resource' do
    subject(:method_call) do
      -> { authorizer.remove_resource(source_record) }
    end

    context 'authorized for destroy? on record' do
      before { allow_action('destroy?', source_record) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for destroy? on record' do
      before { disallow_action('destroy?', source_record) }
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end
  end

  describe '#create_to_many_relationship' do
    let(:related_records) { Array.new(3) { Comment.new } }
    subject(:method_call) do
      -> { authorizer.create_to_many_relationship(source_record, related_records, :comments) }
    end

    context 'authorized for allow_relationship_comments? on record' do
      before { allow_action('allow_relationship_comments?', source_record) }
      it { is_expected.not_to raise_error }
    end

    context 'authorized for update? on record' do
      before { allow_action('update?', source_record) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for update? on record' do
      before do
        disallow_action('allow_relationship_comments?', source_record)
        disallow_action('update?', source_record)
      end
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end

    context 'where allow_relationship_<type>? not defined' do
      let(:related_records) { Array.new(3) { Tag.new } }
      subject(:method_call) do
        -> { authorizer.create_to_many_relationship(source_record, related_records, :tags) }
      end

      context 'authorized for update? on record' do
        before { allow_action('update?', source_record) }
        it { is_expected.not_to raise_error }
      end

      context 'unauthorized for update? on record' do
        before { disallow_action('update?', source_record) }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end
  end

  describe '#remove_to_many_relationship' do
    let(:article) { articles(:article_with_comments) }
    let(:comments_to_remove) { article.comments.limit(2) }
    subject(:method_call) do
      -> { authorizer.remove_to_many_relationship(article, comments_to_remove, :comments) }
    end

    context 'authorized for remove_from_comments? on article' do
      before { allow_action('remove_from_comments?', article) }
      it { is_expected.not_to raise_error }
    end

    context 'authorized for update? on article' do
      before { allow_action('update?', article) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for update? on article' do
      before do
        disallow_action('remove_from_comments?', article)
        disallow_action('update?', article)
      end
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end

    context 'where remove_from_<type>? not defined' do
      let(:tags_to_remove) { article.tags.limit(2) }
      subject(:method_call) do
        -> { authorizer.create_to_many_relationship(article, tags_to_remove, :tags) }
      end

      context 'authorized for update? on article' do
        before { allow_action('update?', article) }
        it { is_expected.not_to raise_error }
      end

      context 'unauthorized for update? on article' do
        before { disallow_action('update?', article) }
        it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
      end
    end
  end

  describe '#include_has_many_resource' do
    let(:record_class) { Article }
    let(:source_record) { Comment.new }
    subject(:method_call) do
      -> { authorizer.include_has_many_resource(source_record, record_class) }
    end

    context 'authorized for index? on record class' do
      before { allow_action('index?', record_class) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for index? on record class' do
      before { disallow_action('index?', record_class) }
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end
  end

  describe '#include_has_one_resource' do
    let(:related_record) { Article.new }
    let(:source_record) { Comment.new }
    subject(:method_call) do
      -> { authorizer.include_has_one_resource(source_record, related_record) }
    end

    context 'authorized for show? on record' do
      before { allow_action('show?', related_record) }
      it { is_expected.not_to raise_error }
    end

    context 'unauthorized for show? on record' do
      before { disallow_action('show?', related_record) }
      it { is_expected.to raise_error(::Pundit::NotAuthorizedError) }
    end
  end
end
