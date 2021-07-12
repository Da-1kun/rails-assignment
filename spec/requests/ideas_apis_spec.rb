require 'rails_helper'

RSpec.describe 'IdeasApis', type: :request do
  # 初期データ作成
  let(:category_a) { FactoryBot.create(:category, name: 'アプリ') }
  let(:category_b) { FactoryBot.create(:category, name: '会議') }

  let!(:idea_a) { FactoryBot.create(:idea, body: 'タスク管理ツール', category_id: category_a.id) }
  let!(:idea_b) { FactoryBot.create(:idea, body: 'オンラインでブレスト', category_id: category_b.id) }

  describe 'アイデア登録API' do
    it 'リクエストのcategory_nameがcategoriesテーブルのnameに存在する場合' do
      valid_params = { category_name: 'アプリ', body: 'チャットアプリ作成' }

      # データが作成されている事を確認
      expect do
        post '/api/v1/ideas', params: { idea: valid_params }
      end.to change(Idea, :count).by(+1).and change(Category, :count).by(+0)

      # リクエスト成功を表す201が返ってきたか確認する。
      expect(response.status).to eq(201)
    end

    it 'リクエストのcategory_nameがcategoriesテーブルのnameに存在しない場合' do
      valid_params = { category_name: '進捗', body: 'スクラム' }

      # データが作成されている事を確認
      expect do
        post '/api/v1/ideas', params: { idea: valid_params }
      end.to change(Idea, :count).by(+1).and change(Category, :count).by(+1)

      # リクエスト成功を表す201が返ってきたか確認する。
      expect(response.status).to eq(201)
    end

    it 'リクエストのcategory_nameが空文字場合' do
      valid_params = { category_name: '', body: 'チャットアプリ作成' }

      # データが作成されていない事を確認
      expect do
        post '/api/v1/ideas', params: { idea: valid_params }
      end.to change(Idea, :count).by(+0).and change(Category, :count).by(+0)

      # リクエスト失敗を表す422が返ってきたか確認する。
      expect(response.status).to eq(422)
    end

    it 'リクエストのbodyが空文字場合' do
      valid_params = { category_name: '進捗', body: '' }

      # データが作成されていない事を確認
      expect do
        post '/api/v1/ideas', params: { idea: valid_params }
      end.to change(Idea, :count).by(+0).and change(Category, :count).by(+1)

      # リクエスト失敗を表す422が返ってきたか確認する。
      expect(response.status).to eq(422)
    end
  end

  describe 'アイデア取得API' do
    it 'category_nameが指定されていない場合' do
      get '/api/v1/ideas', params: { category_name: '' }

      # ideaが全件返ってきたか確認する。
      expect(JSON.parse(response.body)['data'].length).to eq(Idea.count)
    end

    it 'category_nameが指定されている場合' do
      get '/api/v1/ideas', params: { category_name: 'アプリ' }

      # 指定したカテゴリのアイディアが取得できたか確認
      data = JSON.parse(response.body)['data']
      data.each do |item|
        expect(item['name']).to eq('アプリ')
      end
    end

    it '登録されていないカテゴリーのリクエストの場合' do
      get '/api/v1/ideas', params: { category_name: '未登録' }

      # リクエスト失敗を表す404が返ってきたか確認する。
      expect(response.status).to eq(404)
    end
  end
end
