import { mount } from "@vue/test-utils";
import App from "components/app.vue";

describe("App.vue", () => {
  const componentFactory = (values = {}) => {
    return mount(App, {
      data: { ...values },
    });
  };

  describe("processSpecies", () => {
    const subject = componentFactory().vm.processSpecies;

    it("returns one word when given one word", () => {
      const newTaxon = { species: "species" };
      const result = subject(newTaxon);
      expect(result).toEqual("species");
    });

    it("returns 2nd word when given 1 uppercase and 1 lowercase words", () => {
      const newTaxon = { species: "Genus species" };
      const result = subject(newTaxon);
      expect(result).toEqual("species");
    });

    it("returns remaning words when given 1 uppercase and many lowercase words", () => {
      const newTaxon = { species: "Genus species more" };
      const result = subject(newTaxon);
      expect(result).toEqual("species more");
    });

    it("returns all word when given lowercase first word", () => {
      const newTaxon = { species: "species more" };
      const result = subject(newTaxon);
      expect(result).toEqual("species more");
    });

    it("returns undefined when species is undefined", () => {
      const newTaxon = { species: undefined };
      const result = subject(newTaxon);
      expect(result).toEqual(undefined);
    });

    it("trims extra spaces", () => {
      const newTaxon = { species: " species " };
      const result = subject(newTaxon);
      expect(result).toEqual("species");
    });
  });

  describe("processCanonicalName", () => {
    const subject = componentFactory().vm.processCanonicalName;

    describe("when rank is species", () => {
      it("returns genus and species", () => {
        const newTaxon = {
          rank: "species",
          genus: "Genus_1",
          species: "species_1",
        };
        const result = subject(newTaxon);
        expect(result).toEqual("Genus_1 species_1");
      });

      it("returns genus and species", () => {
        const newTaxon = {
          rank: "species",
          genus: "Genus_1",
          species: "Genus_1 species_1",
        };
        const result = subject(newTaxon);
        expect(result).toEqual("Genus_1 species_1");
      });

      it("trims extra spaces", () => {
        const newTaxon = {
          rank: "species",
          genus: " Genus_1 ",
          species: " species_1 ",
        };
        const result = subject(newTaxon);
        expect(result).toEqual("Genus_1 species_1");
      });

      it("returns undefined when species is undefined", () => {
        const newTaxon = {
          rank: "species",
          genus: " Genus_1 ",
          species: undefined,
        };
        const result = subject(newTaxon);
        expect(result).toEqual(undefined);
      });

      it("returns undefined when genus is undefined", () => {
        const newTaxon = {
          rank: "species",
          genus: undefined,
          species: "species_1",
        };
        const result = subject(newTaxon);
        expect(result).toEqual(undefined);
      });
    });

    describe("when rank is class", () => {
      it("returns class", () => {
        const newTaxon = {
          rank: "class",
          class: "Class_1",
        };
        const result = subject(newTaxon);
        expect(result).toEqual("Class_1");
      });

      it("trims extra spaces", () => {
        const newTaxon = {
          rank: "class",
          class: " Class_1 ",
        };
        const result = subject(newTaxon);
        expect(result).toEqual("Class_1");
      });

      it("returns undefined when class is undefined", () => {
        const newTaxon = {
          rank: "class",
          class: undefined,
        };
        const result = subject(newTaxon);
        expect(result).toEqual(undefined);
      });
    });

    it("returns matching taxonomy for a given rank", () => {
      const newTaxon = {
        rank: "kingdom",
        kingdom: "Kingdom_1",
      };
      const result = subject(newTaxon);
      expect(result).toEqual("Kingdom_1");
    });

    it("trims extra spaces", () => {
      const newTaxon = {
        rank: "kingdom",
        kingdom: " Kingdom_1 ",
      };
      const result = subject(newTaxon);
      expect(result).toEqual("Kingdom_1");
    });

    it("returns undefinded if taxonomy is undefined", () => {
      const newTaxon = {
        rank: "kingdom",
        kingdom: undefined,
      };
      const result = subject(newTaxon);
      expect(result).toEqual(undefined);
    });
  });

  describe("trimObject", () => {
    const subject = componentFactory().vm.trimObject;

    it("trims the values for a given object", () => {
      var object = {
        a: 1,
        b: " b ",
        c: { c1: " c " },
      };
      const result = subject(object);
      const expected = {
        a: 1,
        b: "b",
        c: { c1: " c " },
      };

      expect(result).toEqual(expected);
    });

    it("does not change the original object", () => {
      var object = { a: " a " };
      subject(object);

      expect(object).toEqual(object);
    });
  });
});
