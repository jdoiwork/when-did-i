import { Elm } from '../Elm/Main.elm'

import { TaskItem } from '../models/task-item'
import { ChangeEvent } from '../services/database/types';

interface InitArgs {
    node?: HTMLElement;
    flags?: Flags;
}

interface Flags {
    // initialValue: string;
}

export type Provider = "google" | "facebook" | "twitter" | "github"

export type Status = "login" | "logout" | "checking"

export class ElmAppAdapter {
    app: any;
    constructor(initArgs: InitArgs) {
        this.app = Elm.Main.init(initArgs)
    }

    loginWith(callback: (provider: Provider) => void) : void {
        this.app.ports.loginWith.subscribe(callback)
    }

    loginStatusChanged(status: Status) : void {
        this.app.ports.loginStatusChanged.send(status)
    }

    logout(callback: () => void) {
        this.app.ports.logout.subscribe(callback)
    }

    postNewItem(callback: (text: string) => void) {
        this.app.ports.postNewItem.subscribe(callback)
    }

    // createdNewItem
    createdNewItem(newItem: TaskItem) : void {
        this.app.ports.createdNewItem.send(newItem)
    }

    // updatedItems
    updatedItems(newItems: Array<[ChangeEvent, TaskItem]>) : void {
        this.app.ports.updatedItems.send(newItems)
    }

    // patchItemDidIt
    patchItemDidIt(callback: (uid: string) => void) : void {
        this.app.ports.patchItemDidIt.subscribe(callback)
    }
    
    // deleteItem
    deleteItem(callback: (uid: string) => void) : void {
        this.app.ports.deleteItem.subscribe(callback)
    }

    // patchItem
    patchItem(callback: (taskItem: TaskItem) => void) : void {
        this.app.ports.patchItem.subscribe(callback)
    }
}
