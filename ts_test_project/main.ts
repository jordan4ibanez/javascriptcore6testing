import { ACoolTest } from "./testing";

console.log("test 1 2 3")

class F {
    cool: number = 1;
}

class T {
    test?: F;
}

console.log(new T().test!.cool)

const t = new ACoolTest();

