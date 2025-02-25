require "../../spec_helper"

describe MartenTurbo::Template::Tag::DomId do
  describe "::new" do
    it "raises if the dom_id block does not contain at least one argument" do
      parser = Marten::Template::Parser.new("{% dom_id %}")

      expect_raises(
        Marten::Template::Errors::InvalidSyntax,
        "Malformed dom_id tag: one or two arguments must be provided"
      ) do
        MartenTurbo::Template::Tag::DomId.new(parser, "dom_id")
      end
    end

    it "raises if the dom_id block does contain more then two arguments" do
      parser = Marten::Template::Parser.new("{% dom_id 1 2 3 %}")

      expect_raises(
        Marten::Template::Errors::InvalidSyntax,
        "Malformed dom_id tag: one or two arguments must be provided"
      ) do
        MartenTurbo::Template::Tag::DomId.new(parser, "dom_id")
      end
    end
  end

  describe "#render" do
    it "renders the correct dom id for a saved marten model" do
      parser = Marten::Template::Parser.new("")
      tag = Tag.create!(name: "Marten Turbo")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag")

      context = Marten::Template::Context{"tag" => tag}

      dom_id.render(context).should eq "tag_#{tag.pk}"
    end

    it "renders the correct dom id for a saved marten model with a prefix" do
      parser = Marten::Template::Parser.new("")
      tag = Tag.create!(name: "Marten Turbo")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag 'edit'")

      context = Marten::Template::Context{"tag" => tag}

      dom_id.render(context).should eq "edit_tag_#{tag.pk}"
    end

    it "renders the correct dom id for a non-saved marten model" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag")

      context = Marten::Template::Context{"tag" => Tag.new}

      dom_id.render(context).should eq "new_tag"
    end

    it "renders the correct dom id for a non-saved marten model" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag 'prefix'")

      context = Marten::Template::Context{"tag" => Tag.new}

      dom_id.render(context).should eq "prefix_new_tag"
    end

    it "renders the correct dom id for a saved marten model with a namespace" do
      parser = Marten::Template::Parser.new("")
      tag = Namespaced::Tag.create!(name: "Marten Turbo")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag")

      context = Marten::Template::Context{"tag" => tag}

      dom_id.render(context).should eq "namespaced_tag_#{tag.pk}"
    end

    it "renders the correct dom id for a non-saved marten model with a namespace" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag")

      context = Marten::Template::Context{"tag" => Namespaced::Tag.new}

      dom_id.render(context).should eq "new_namespaced_tag"
    end

    it "renders the correct dom id for a non-saved marten model with a namespace" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag 'prefix'")

      context = Marten::Template::Context{"tag" => Namespaced::Tag.new}

      dom_id.render(context).should eq "prefix_new_namespaced_tag"
    end

    it "renders the correct dom id for a saved marten model with a prefix" do
      parser = Marten::Template::Parser.new("")
      tag = Namespaced::Tag.create!(name: "Marten Turbo")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id tag 'edit'")

      context = Marten::Template::Context{"tag" => tag}

      dom_id.render(context).should eq "edit_namespaced_tag_#{tag.pk}"
    end

    it "renders the correct dom id for an int" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id 1")

      context = Marten::Template::Context.new

      dom_id.render(context).should eq "1"
    end

    it "renders the correct dom id for an int and a prefix" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id 1 'edit'")

      context = Marten::Template::Context.new

      dom_id.render(context).should eq "edit_1"
    end

    it "renders the correct dom id for a string" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id 'custom_id'")

      context = Marten::Template::Context.new

      dom_id.render(context).should eq "custom_id"
    end

    it "renders the correct dom id for a string and a prefix" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id 'custom_id' 'edit'")

      context = Marten::Template::Context.new

      dom_id.render(context).should eq "edit_custom_id"
    end

    it "renders the correct dom id for a non-model variable" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id my_var")

      context = Marten::Template::Context{"my_var" => "custom_id"}

      dom_id.render(context).should eq "custom_id"
    end

    it "renders the correct dom id for a non-model variable and a prefix" do
      parser = Marten::Template::Parser.new("")

      dom_id = MartenTurbo::Template::Tag::DomId.new(parser, "dom_id my_var 'edit'")

      context = Marten::Template::Context{"my_var" => "custom_id"}

      dom_id.render(context).should eq "edit_custom_id"
    end
  end
end
