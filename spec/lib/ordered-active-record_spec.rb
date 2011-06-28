require 'spec_helper'

describe 'A model Post' do
  context 'with acts_as_ordered enabled on column "position"' do
    before do
      Post.delete_all
      Post.create(:text => '1st post', :position => 1)
      Post.create(:text => '2nd post', :position => 2)
      Post.create(:text => '3rd post', :position => 3)
    end

    it 'should have 3 posts' do
      Post.count.should == 3
      Post.find_by_text('1st post').position.should == 1
      Post.find_by_text('2nd post').position.should == 2
      Post.find_by_text('3rd post').position.should == 3
    end

    it 'should insert a record with position 2' do
      post = Post.create(:text => 'Inserted at position 2', :position => 2)
      post.position.should == 2
      Post.count.should == 4
      Post.find_by_text('1st post').position.should == 1
      Post.find_by_text('2nd post').position.should == 3
      Post.find_by_text('3rd post').position.should == 4
    end

    it 'should delete a record at position 2' do
      Post.find_by_text('2nd post').destroy
      Post.count.should == 2
      Post.find_by_text('1st post').position.should == 1
      Post.find_by_text('3rd post').position.should == 2
    end

    it 'should move the record down from position 1 to position 3' do
      Post.find_by_text('1st post').update_attribute(:position, 3)
      Post.count.should == 3
      Post.find_by_text('2nd post').position.should == 1
      Post.find_by_text('3rd post').position.should == 2
      Post.find_by_text('1st post').position.should == 3
    end

    it 'should move the record up from position 3 to position 1' do
      Post.find_by_text('3rd post').update_attribute(:position, 1)
      Post.count.should == 3
      Post.find_by_text('3rd post').position.should == 1
      Post.find_by_text('1st post').position.should == 2
      Post.find_by_text('2nd post').position.should == 3
    end

    it 'should insert a record with position 5' do
      post = Post.create(:text => 'Inserted at position 5', :position => 5)
      post.position.should == 5
      Post.count.should == 4
      Post.find_by_text('1st post').position.should == 1
      Post.find_by_text('2nd post').position.should == 2
      Post.find_by_text('3rd post').position.should == 3
    end
  end
end