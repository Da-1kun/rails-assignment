module Api
  module V1
    class IdeasController < ApplicationController
      before_action :set_category, only: [:create]

      def create
        # idea新規登録
        idea = Idea.new(category_id: @category[:id], body: idea_params[:body])

        if idea.save
          render status: :created
        else
          render status: :unprocessable_entity
        end
      end

      def index
        category_name = params[:category_name]

        if category_name.blank?
          # category_nameが指定されていない場合は全てのideasを返却
          render json: { data: format_json(Idea.data.all) }
          return
        end

        unless Category.find_by(name: category_name)
          # 登録されていないカテゴリーのリクエストの場合
          render status: :not_found
          return
        end

        # category_nameが指定されている場合は該当するcategoryのideasの一覧を返却
        render json: { data: format_json(Idea.data.getByName(category_name)) }
      end

      private

      def idea_params
        params.require(:idea).permit(:category_name, :body)
      end

      def set_category
        @category = Category.find_or_initialize_by(name: idea_params[:category_name])

        # 新たなcategoryの場合categoriesテーブルに登録
        create_category if @category.new_record?
      end

      def create_category
        render status: :unprocessable_entity and return unless @category.save
      end

      # created_atをunixに変換
      def format_json(result_list)
        list = []

        result_list.each do |item|
          item = {
            id: item.id, name: item.name,
            body: item.body, created_at: item.created_at.to_i
          }
          list.push(item)
        end

        list
      end
    end
  end
end
